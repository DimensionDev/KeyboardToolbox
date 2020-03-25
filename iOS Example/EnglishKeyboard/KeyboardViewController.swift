//
//  KeyboardViewController.swift
//  EnglishKeyboard
//
//  Created by Cirno MainasuK on 2020-3-25.
//  Copyright © 2020 dimension. All rights reserved.
//

import os
import UIKit
import EnglishKeyboardKit

class KeyboardViewController: UIInputViewController {

    let keyboardViewController = EnglishKeyboardViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        os_log("%{public}s[%{public}ld], %{public}s: traitCollection.horizontalSizeClass=%{public}s | traitCollection.verticalSizeClass=%{public}s", ((#file as NSString).lastPathComponent), #line, #function, traitCollection.horizontalSizeClass.description, traitCollection.verticalSizeClass.description)
        
        // Layout KeyboardViewController
        guard let inputView = self.inputView else {
            assertionFailure()
            return
        }
        
        let placehoder = UIView()
        placehoder.translatesAutoresizingMaskIntoConstraints = false
        inputView.addSubview(placehoder)
        NSLayoutConstraint.activate([
            placehoder.topAnchor.constraint(equalTo: inputView.topAnchor),
            placehoder.leftAnchor.constraint(equalTo: inputView.leftAnchor),
            placehoder.rightAnchor.constraint(equalTo: inputView.rightAnchor),
            placehoder.heightAnchor.constraint(equalToConstant: 60),
        ])
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        placehoder.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: placehoder.topAnchor),
            label.leadingAnchor.constraint(equalTo: placehoder.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: placehoder.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: placehoder.bottomAnchor),
        ])
        
        label.text = "KeyboardToolbox"
        label.textAlignment = .center
        
        addChild(keyboardViewController)
        keyboardViewController.view.translatesAutoresizingMaskIntoConstraints = false
        inputView.addSubview(keyboardViewController.view)
        NSLayoutConstraint.activate([
            keyboardViewController.view.topAnchor.constraint(equalTo: placehoder.bottomAnchor),
            keyboardViewController.view.leftAnchor.constraint(equalTo: inputView.leftAnchor),
            keyboardViewController.view.rightAnchor.constraint(equalTo: inputView.rightAnchor),
            keyboardViewController.view.bottomAnchor.constraint(equalTo: inputView.bottomAnchor),
        ])
        keyboardViewController.didMove(toParent: self)
        
        keyboardViewController.keyboardView.delegate = self
        keyboardViewController.textDocumentProxy = textDocumentProxy
    }
    
}

extension KeyboardViewController {
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
    }
    
}

// MARK: - UITextInputDelegate
extension KeyboardViewController {
    
    override public func selectionWillChange(_ textInput: UITextInput?) {
        // Use UITextDocumentProxy. Not textInput
        keyboardViewController.keyboardView.inputDelegate?.selectionDidChange(nil)
    }
    
    override public func selectionDidChange(_ textInput: UITextInput?) {
        // Use UITextDocumentProxy. Not textInput
        keyboardViewController.keyboardView.inputDelegate?.selectionDidChange(nil)
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // Use UITextDocumentProxy. Not textInput
        keyboardViewController.keyboardView.inputDelegate?.textWillChange(nil)
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // Use UITextDocumentProxy. Not textInput
        keyboardViewController.keyboardView.inputDelegate?.textDidChange(nil)
    }

}

// MARK: - KeyboardViewDelegate
extension KeyboardViewController: KeyboardViewDelegate {
    
    func requestHandleInputModeList(_ keyboardView: KeyboardView, keyView: KeyView) {
        keyView.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
    }
    
    func needsInputModeSwitchKey(_ keyboardView: KeyboardView) -> Bool {
        os_log("%{public}s[%{public}ld], %{public}s: %s", ((#file as NSString).lastPathComponent), #line, #function, needsInputModeSwitchKey.description)
        return needsInputModeSwitchKey
    }
    
}
