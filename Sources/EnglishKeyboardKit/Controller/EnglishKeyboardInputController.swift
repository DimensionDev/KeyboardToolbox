//
//  EnglishKeyboardInputController.swift
//  
//
//  Created by Cirno MainasuK on 2020-3-25.
//

import os
import UIKit
import Combine
import KeyboardCore

open class EnglishKeyboardInputController: NSObject {
    
    var disposeBag = Set<AnyCancellable>()
    
    public let preferences: Preferences
    
    public weak var textInput: UITextInput?
    public weak var textDocumentProxy: UITextDocumentProxy?
    public weak var keyboardView: KeyboardView?
    
    private var lastInputSpaceTimestamp = Date()
    
    private let textDidChange = PassthroughSubject<UITextInput?, Never>()
    
    public init(preferences: Preferences = Preferences()) {
        self.preferences = preferences
        super.init()
        
        textDidChange
            .receive(on: DispatchQueue.main)
            .debounce(for: 0.15, scheduler: DispatchQueue.main)
            .sink { _ in
                self.handleAutoCapitalization()
        }
        .store(in: &disposeBag)
    }
    
}

extension EnglishKeyboardInputController {
    
    public class Preferences {
        var periodShortcut = true
        var smartQuotes = true
        var autoCapitalization = true
        
        public init() { }
    }
    
}

// MARK: - KeyboardViewInputDelgate
extension EnglishKeyboardInputController: KeyboardViewInputDelgate {
    
    public func keyboardView(_ keyboardView: KeyboardView, didInputText text: String, sender: KeyView) {
        textDocumentProxy?.insertText(text)
        
        handleAutoPeriod(text)
        handleSmartQuotes(text)
        handleAutoCapitalization(text)
    }
    
    public func deleteBackward(_ keyboardView: KeyboardView) {
        textDocumentProxy?.deleteBackward()
        
        handleAutoCapitalization()
    }
    
    public func canRestorePage(_ keyboardView: KeyboardView, page: Page) -> Bool {
        return true
    }
    
}

extension EnglishKeyboardInputController {
    
    /// Handle auto period after user type
    /// - Parameter text: the text just typed
    func handleAutoPeriod(_ text: String) {
        guard preferences.periodShortcut else { return }
        
        guard text == " " else { return }
        defer {
            lastInputSpaceTimestamp = Date()
        }
        
        // Do not handle auto peroid if interval too long
        guard lastInputSpaceTimestamp.timeIntervalSinceNow > -0.33 else {
            return
        }
        
        
        guard let proxy = textDocumentProxy else { return }
        let shouldHandlePeriod = proxy.documentContextBeforeInput.flatMap { input -> Bool in
            guard input.count >= 3 else { return false }
            var index = input.endIndex
            
            index = input.index(before: index)
            guard input[index] == " " else { return false }
            
            index = input.index(before: index)
            guard input[index] == " " else { return false }
            
            index = input.index(before: index)
            let char = input[index]
            guard !char.isPunctuation && !char.isWhitespace else { return false }
            
            return true
            } ?? false
        
        guard shouldHandlePeriod else { return }
        
        proxy.deleteBackward()  // remove the space jsut type
        proxy.deleteBackward()  // remove the space before type
        proxy.insertText(".")   // insert .
        proxy.insertText(" ")   // restore space just type
    }
    
    /// Handle smart quotes after user type
    /// - Parameter text: the text just typed
    func handleSmartQuotes(_ text: String) {
        guard preferences.smartQuotes else { return }
        if let textInput = textInput, textInput.smartQuotesType == UITextSmartQuotesType.no {
            return
        }
        
        guard text == "'" || text == "\"" else { return }
        guard let proxy = textDocumentProxy else { return }
        guard let input = proxy.documentContextBeforeInput else { return }
        
        let shouldReplaceByOpenQuotes: Bool = {
            guard input.count > 1 else {
                // only quote
                return true
            }
            
            var index = input.index(before: input.endIndex)
            guard input[index] == "'" || input[index] == "\"" else {
                assertionFailure()
                return true
            }
            
            index = input.index(before: index)
            return input[index].isWhitespace ? true : false
        }()
        
        if shouldReplaceByOpenQuotes {
            if text == "'" {
                proxy.deleteBackward()
                proxy.insertText("‘")
            }
            
            if text == "\"" {
                proxy.deleteBackward()
                proxy.insertText("“")
            }
        } else {
            if text == "'" {
                proxy.deleteBackward()
                proxy.insertText("’")
            }
            
            if text == "\"" {
                proxy.deleteBackward()
                proxy.insertText("”")
            }
        }
    }
    
    /// Handle auto capitalization after user typing
    /// - Parameter text: the text just typed
    func handleAutoCapitalization(_ text: String?) {
        guard preferences.autoCapitalization else { return }
        guard let keyboardView = keyboardView else { return }
        
        var shouldCapitalization = false
        defer {
            if shouldCapitalization {
                keyboardView.shiftStateMachine.enter(ShiftState.Enabled.self)
                os_log("%{public}s[%{public}ld], %{public}s: shift enable", ((#file as NSString).lastPathComponent), #line, #function)
            } else {
                keyboardView.resetShift()
                os_log("%{public}s[%{public}ld], %{public}s: shift disable", ((#file as NSString).lastPathComponent), #line, #function)
            }
        }
        
        if keyboardView.shiftState == .locked {
            shouldCapitalization = false
            return
        }
        
        guard text == " " else { return }
        guard let proxy = textDocumentProxy else { return }
        guard let input = proxy.documentContextBeforeInput else { return }
        guard !input.isEmpty else { return }
        
        var index = input.index(before: input.endIndex)
        guard input[index] == " " else { return }
        
        while index > input.startIndex, input[index].isWhitespace {
            index = input.index(before: index)
        }
        
        let nonWhitespaceChar = input[index]
        if nonWhitespaceChar == "." || nonWhitespaceChar == "!" || nonWhitespaceChar == "?" {
            shouldCapitalization = true
        } else {
            shouldCapitalization = false
        }
        
    }
    
    /// Handle auto capitalization when text input changed
    func handleAutoCapitalization() {
        guard preferences.autoCapitalization else { return }
        
        guard let input = textDocumentProxy?.documentContextBeforeInput, let last = input.last else {
            keyboardView?.shiftStateMachine.enter(ShiftState.Enabled.self)
            os_log("%{public}s[%{public}ld], %{public}s: no input. force shift enable", ((#file as NSString).lastPathComponent), #line, #function)
            return
        }
        os_log("%{public}s[%{public}ld], %{public}s: input: %s", ((#file as NSString).lastPathComponent), #line, #function, input)
        
        handleAutoCapitalization(String(last))
    }
    
}

// MARK: - UITextInputDelegate
extension EnglishKeyboardInputController: UITextInputDelegate {
    
    public func selectionWillChange(_ textInput: UITextInput?) {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)
    }
    
    public func selectionDidChange(_ textInput: UITextInput?) {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)
    }
    
    public func textWillChange(_ textInput: UITextInput?) {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)
    }
    
    /// Text input changed. Handle auto captalize update here
    /// - Parameter textInput: always nil in keyboard extension
    public func textDidChange(_ textInput: UITextInput?) {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)
        
        textDidChange.send(textInput)
    }
    
}

