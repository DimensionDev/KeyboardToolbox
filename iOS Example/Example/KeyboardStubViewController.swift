//
//  KeyboardStubViewController.swift
//  Example
//
//  Created by Cirno MainasuK on 2020-3-25.
//  Copyright © 2020 dimension. All rights reserved.
//

import os
import UIKit
import EnglishKeyboardKit

final class KeyboardStubViewController: UIViewController {
    
    let textField = UITextField()
    let textField2 = UITextField()
    let keyboardViewController = EnglishKeyboardViewController()
    
}

extension KeyboardStubViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(keyboardViewController)
        keyboardViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(keyboardViewController.view)
        keyboardViewController.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            keyboardViewController.view.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 100),
            keyboardViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboardViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: keyboardViewController.view.bottomAnchor, constant: 16),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textField.heightAnchor.constraint(equalToConstant: 44),
        ])
        
        textField2.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField2)
        NSLayoutConstraint.activate([
            textField2.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 16),
            textField2.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textField2.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textField2.heightAnchor.constraint(equalToConstant: 44),
        ])
        
        
        keyboardViewController.view.backgroundColor = .systemGray5
        
        // Setup text fields
        textField.backgroundColor = .systemGray5
        textField2.backgroundColor = .systemGray5
        textField.inputDelegate = keyboardViewController.keyboardView.inputDelegate
        textField2.inputDelegate = keyboardViewController.keyboardView.inputDelegate
        
        // Setup keyboard view
        keyboardViewController.keyboardView.delegate = self
        keyboardViewController.keyboardView.needsPlayClickSound = true
        
        // Setup controller
        keyboardViewController.textDocumentProxy = textField
    }
    
}

// MARK: - KeyboardViewDelegate
extension KeyboardStubViewController: KeyboardViewDelegate {
    
    func requestHandleInputModeList(_ keyboardView: KeyboardView, keyView: KeyView) {
        // UIInputViewController implementation stub
        keyView.addTarget(self, action: #selector(KeyboardStubViewController.handleInputModeList(_:)), for: .allTouchEvents)
    }
    
    @objc private func handleInputModeList(_ sender: KeyView) {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)
    }
    
    func needsInputModeSwitchKey(_ keyboardView: KeyboardView) -> Bool {
        return true
    }
    
}

// MARK: - UIInputViewAudioFeedback
extension KeyboardStubViewController: UIInputViewAudioFeedback {
    
    var enableInputClicksWhenVisible: Bool { return true }
}
