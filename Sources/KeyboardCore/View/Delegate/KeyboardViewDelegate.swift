//
//  KeyboardViewDelegate.swift
//  
//
//  Created by Cirno MainasuK on 2020-3-25.
//

import Foundation

public protocol KeyboardViewDelegate: class {
    
    /// Request delegate add a `UIInputViewController` as target to handle the `handleInputModeList(from:with:)` selector to `keyView`
    ///
    /// ## Note:
    /// For example make  the UIInputViewController trigger input mode list  for any type touch from keyView:
    ///
    /// `keyView.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)`
    ///
    /// - Parameters:
    ///   - keyboardView: delegate caller
    ///   - keyView: the KeyView to trigger input mode list display
    func requestHandleInputModeList(_ keyboardView: KeyboardView, keyView: KeyView)
    
    
    /// Request delegate if needs display input mode switch key (globe key)
    /// - Parameter keyboardView: delegate caller
    func needsInputModeSwitchKey(_ keyboardView: KeyboardView) -> Bool
    
}
