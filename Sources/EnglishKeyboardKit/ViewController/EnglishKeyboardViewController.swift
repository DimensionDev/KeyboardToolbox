//
//  EnglishKeyboardViewController.swift
//  
//
//  Created by Cirno MainasuK on 2020-3-25.
//

import os
import UIKit
import KeyboardCore

final public class EnglishKeyboardViewController: UIViewController {
    
    public let keyboardLayout = EnglishKeyboardLayout()
    public let keyboardView = KeyboardView()
    
    private var viewHeightAnchorLayoutConstraint: NSLayoutConstraint!
    
    let englishKeyboard = EnglishKeyboard()
    let englishKeyboardInputController = EnglishKeyboardInputController()
    
    public weak var textDocumentProxy: UITextDocumentProxy? {
        didSet {
            englishKeyboardInputController.textDocumentProxy = textDocumentProxy
        }
    }
    
}

extension EnglishKeyboardViewController {
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        viewHeightAnchorLayoutConstraint = view.heightAnchor.constraint(equalToConstant: 0)
        viewHeightAnchorLayoutConstraint.isActive = true
        
        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(keyboardView)
        NSLayoutConstraint.activate([
            keyboardView.topAnchor.constraint(equalTo: view.topAnchor),
            keyboardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        keyboardView.layout = keyboardLayout
        
        // could overload by framework user
        keyboardView.delegate = self
        keyboardView.dataSource = self
        keyboardView.inputDelegate = englishKeyboardInputController
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        keyboardLayout.invalidateLayout()
        view.needsUpdateConstraints()
    }
    
    public override func updateViewConstraints() {
        super.updateViewConstraints()
        
        let screen = view.window?.screen ?? UIScreen.main
        let keyboardHeight = EnglishKeyboardViewLayoutSettings.keyboardHeight(for: view.bounds.width, in: screen.scale)
        viewHeightAnchorLayoutConstraint.constant = keyboardHeight
        
        os_log("%{public}s[%{public}ld], %{public}s: update keyboard height: %{public}s", ((#file as NSString).lastPathComponent), #line, #function, keyboardHeight.description)
    }
    
}

// MARK: - KeyboardViewDataSource
// Default implement.
extension EnglishKeyboardViewController: KeyboardViewDataSource {
    
    public func numberOfKeyboard() -> Int {
        return 1
    }
    
    
    public func keyboardView(_ keyboardView: KeyboardView, keyboardAt index: Int) -> Keyboard {
        return englishKeyboard
    }
    
}

// MARK: - KeyboardViewDelegate
// Default implement.
extension EnglishKeyboardViewController: KeyboardViewDelegate {
    
    public func requestHandleInputModeList(_ keyboardView: KeyboardView, keyView: KeyView) {
        // do nothing
    }
    
    public func needsInputModeSwitchKey(_ keyboardView: KeyboardView) -> Bool {
        return true
    }
    
}
