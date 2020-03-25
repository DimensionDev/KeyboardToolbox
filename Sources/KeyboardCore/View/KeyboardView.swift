//
//  KeyboardView.swift
//  
//
//  Created by Cirno MainasuK on 2020-3-24.
//

import os
import UIKit
import GameplayKit
import Combine
import AudioToolbox

/**
 Container view for layout keyboard
 
 The `keyBackgrounds` and `keyCaps` image views draw the keyboard appearance for input keys (a.k.a QWERTY).
 The `trackingView` contains the `UIControl` element for user interact and also contains function key views
 for shift control and delete e.t.c. `KeyboardView` delegate layout details to `KeyboardViewLayout` object and
 delegate the layout data to `KeyboardViewDataSource`.
 */
public class KeyboardView: UIView {
    open weak var delegate: KeyboardViewDelegate?
    open weak var dataSource: KeyboardViewDataSource? {
        didSet {
            reloadData()
        }
    }
    open weak var inputDelegate: (KeyboardViewInputDelgate & UITextInputDelegate)? {
        didSet {
            inputDelegate?.keyboardView = self
        }
    }
    open weak var layout: KeyboardViewLayout? {
        didSet {
            layout?.keyboardView = self
        }
    }
    public var needsPlayClickSound = false
    
    public private(set) var keyboards: [Keyboard] = []
    public private(set) var pages: [Keyboard: [Page]] = [:]
    
    public private(set) var currentKeyboard: Keyboard?
    public private(set) var currentPage: Page?
    
    public let keyBackgrounds = UIImageView()      // keyBackgounds & keyBorders
    public let keyCaps = UIImageView()             // keyCaps
    public let trackingView = ForwardingView()     // for user interactive
    
    // shift
    public lazy var shiftStateMachine: GKStateMachine = {
        let states = [
            ShiftState.Disabled(keyboardView: self),
            ShiftState.Enabled(keyboardView: self),
            ShiftState.Locked(keyboardView: self),
        ]
        return GKStateMachine(states: states)
    }()
    public internal(set) var shiftState = ShiftState.disabled {  // do not direct set this value
        didSet {
            layout?.updateKeyCaps(shiftState: shiftState)
        }
    }
    var shiftStateWhenShiftDown = ShiftState.disabled
    var lastShiftDownTime = Date()
    public var shiftLockThrottle: TimeInterval = 0.3
    
    // shift drag helper
    var isShiftDragExit = false
    
    // page drag helper
    var isPageDragExit = false
    var previousPage: Page?
    
    // backspace
    public var backspaceDelay: TimeInterval = 0.5
    public var backspaceRepeat: TimeInterval = 0.15
    
    // keyboard event publishers
    public let backspaceActiveSubject = CurrentValueSubject<Bool, Never>(false)
    // let backspaceReleasedSubject = CurrentValueSubject<Bool, Never>(true)
    public let spaceActiveSubject = CurrentValueSubject<Bool, Never>(false)
    public let returnActiveSubject = CurrentValueSubject<Bool, Never>(false)
    
    // cancellables for publisher
    private var backspaceRepeatSubjectCancellable: Cancellable?
    private var cancellables = Set<AnyCancellable>()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _init()
    }
    
    private func _init() {
        // Layout keyboard UI
        keyBackgrounds.translatesAutoresizingMaskIntoConstraints = false
        addSubview(keyBackgrounds)
        NSLayoutConstraint.activate([
            keyBackgrounds.topAnchor.constraint(equalTo: topAnchor),
            keyBackgrounds.leftAnchor.constraint(equalTo: leftAnchor),
            keyBackgrounds.rightAnchor.constraint(equalTo: rightAnchor),
            keyBackgrounds.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        keyCaps.translatesAutoresizingMaskIntoConstraints = false
        addSubview(keyCaps)
        NSLayoutConstraint.activate([
            keyCaps.topAnchor.constraint(equalTo: topAnchor),
            keyCaps.leftAnchor.constraint(equalTo: leftAnchor),
            keyCaps.rightAnchor.constraint(equalTo: rightAnchor),
            keyCaps.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        trackingView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(trackingView)
        NSLayoutConstraint.activate([
            trackingView.topAnchor.constraint(equalTo: topAnchor),
            trackingView.leftAnchor.constraint(equalTo: leftAnchor),
            trackingView.rightAnchor.constraint(equalTo: rightAnchor),
            trackingView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        // Setup state machine
        shiftStateMachine.enter(ShiftState.Disabled.self)
        
        // Setup subscriber
        backspaceActiveSubject
            .sink { [weak self] isActive in
                guard let `self` = self else { return }
                
                // FIXME: long press delete then release and presse could make double delete
                
                // manually cancel backspace repeat subscribe
                let cancellable = self.backspaceRepeatSubjectCancellable
                self.backspaceRepeatSubjectCancellable = nil
                cancellable?.cancel()
                
                if let page = self.currentPage, let backspaceKey = page.backspaceKey {
                    self.layout?.update(page: page, functionKey: backspaceKey, in: self)
                }
                
                // setup Timer publisher and autoconnet to it
                guard isActive else {
                    return
                }
                self.backspaceRepeatSubjectCancellable = Timer.publish(every: self.backspaceRepeat, on: .main, in: .default)
                    .autoconnect()
                    .delay(for: .seconds(self.backspaceDelay), scheduler: RunLoop.main)
                    // .print()
                    .sink { [weak self] _ in
                        // Break if backspace not active
                        guard self?.backspaceRepeatSubjectCancellable != nil,
                            self?.backspaceActiveSubject.value == true else {
                                return
                        }
                        self?.deleteBackward()
                        // TODO:
                }
        }
        .store(in: &cancellables)
        
        spaceActiveSubject
            .sink { [weak self] isActive in
                guard let `self` = self else { return }
                guard let page = self.currentPage, let spaceKey = page.spaceKey else {
                    return
                }
                
                self.layout?.update(page: page, functionKey: spaceKey, in: self)
        }
        .store(in: &cancellables)
        
        returnActiveSubject
            .sink { [weak self] isActive in
                guard let `self` = self else { return }
                guard let page = self.currentPage, let returnKey = page.returnKey else {
                    return
                }
                
                self.layout?.update(page: page, functionKey: returnKey, in: self)
        }
        .store(in: &cancellables)
    }
    
    deinit {
        backspaceRepeatSubjectCancellable?.cancel()
    }
    
}

extension KeyboardView {
    
    /// Reload keyboard view data source and layout the first page in data souce
    public func reloadData() {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)
        
        // reset before reload
        reset()
        
        guard let dataSource = dataSource else {
            return
        }
        
        let numberOfKeyboards = dataSource.numberOfKeyboard()
        guard numberOfKeyboards > 0 else {
            return
        }
        
        keyboards = (0..<numberOfKeyboards).map { dataSource.keyboardView(self, keyboardAt: $0) }
        
        let defaultKeyboard = keyboards[0]
        prepare(keyboard: defaultKeyboard)
        
        guard let firstPage = pages[defaultKeyboard]?.first else {
            return
        }
        prepare(page: firstPage)
        layout?.invalidateLayout()
    }
    
    public func load(page: Page) {
        os_log("%{public}s[%{public}ld], %{public}s: %{public}s", ((#file as NSString).lastPathComponent), #line, #function, String(describing: page))
        
        prepare(page: page)
        layout?.invalidateLayout()
    }
    
}

extension KeyboardView {
    
    // reset data model
    private func reset() {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)
        
        // reset keyboard model
        keyboards = []
        pages = [:]
        
        // rest keyboard state
        resetShift()
    }
    
    public func resetShift() {
        shiftStateMachine = {
            let states = [
                ShiftState.Disabled(keyboardView: self),
                ShiftState.Enabled(keyboardView: self),
                ShiftState.Locked(keyboardView: self),
            ]
            return GKStateMachine(states: states)
        }()
        shiftState = ShiftState.disabled
        shiftStateWhenShiftDown = .disabled
        lastShiftDownTime = Date()
    }
    
    // load keyboard pages
    private func prepare(keyboard: Keyboard) {
        os_log("%{public}s[%{public}ld], %{public}s: %{public}s", ((#file as NSString).lastPathComponent), #line, #function, keyboard.languageLayout.description)
        
        guard let keyboardDataSource = keyboard.dataSource else {
            return
        }
        var pages: [Page] = []
        let numberOfPages = keyboardDataSource.numberOfPages()
        for index in 0..<numberOfPages {
            let page = keyboardDataSource.keyboard(keyboard, pageAt: index)
            pages.append(page)
        }
        self.pages[keyboard] = pages
        
        currentKeyboard = keyboard
    }
    
    // load keyboard page layout
    private func prepare(page: Page) {
        os_log("%{public}s[%{public}ld], %{public}s: %{public}s", ((#file as NSString).lastPathComponent), #line, #function, String(describing: page))
        
        // remove page layout
        
        // lazy load keys from data source
        if page.keys.isEmpty {
            page.reloadData()
        }
        
        currentPage = page
    }
    
}

extension KeyboardView {
    
    func playSystemSound(_ systemSoundID: SystemSoundID) {
        guard needsPlayClickSound else { return }
        
        DispatchQueue.main.async {
            os_log("%{public}s[%{public}ld], %{public}s: playSystemSound", ((#file as NSString).lastPathComponent), #line, #function)
            
            AudioServicesPlaySystemSound(systemSoundID)
        }
    }
    
}
