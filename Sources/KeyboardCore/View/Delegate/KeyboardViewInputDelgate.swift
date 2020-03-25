//
//  KeyboardViewInputDelgate.swift
//  
//
//  Created by Cirno MainasuK on 2020-3-25.
//

import Foundation

public protocol KeyboardViewInputDelgate: class {
    
    /// Weak refer constraint for delegate reverse control keyboard view
    var keyboardView: KeyboardView? { get set }
    
    /// Keyboard did input text
    /// - Parameters:
    ///   - keyboardView: delegate caller
    ///   - text: the key cap text for key
    ///   - sender: the trigger keyView
    func keyboardView(_ keyboardView: KeyboardView, didInputText text: String, sender: KeyView)
    
    
    /// Keyboard trigger delete
    /// - Parameter keyboardView: delegate caller
    func deleteBackward(_ keyboardView: KeyboardView)
    
    /// Keyboard request restore previous page if needs. Return false to prevent this behavior.
    /// - Parameters:
    ///   - keyboardView: delegate caller
    ///   - previousPage: the previous page will be restore
    func canRestorePage(_ keyboardView: KeyboardView, page: Page) -> Bool
    
}
