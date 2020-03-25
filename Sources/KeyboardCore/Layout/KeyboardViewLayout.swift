//
//  KeyboardViewLayout.swift
//  
//
//  Created by Cirno MainasuK on 2020-3-25.
//

import UIKit

public protocol KeyboardViewLayout: class {
    var keyboardView: KeyboardView? { get set }
    var settings: KeyboardViewLayoutSettings { get }
    
    /// Invalidate keyboard layout and trigger layout update
    func invalidateLayout()
    
    /// Trigger key appearance update for new shiftState
    func updateKeyCaps(shiftState: ShiftState)
    
    /// Update function key appearance in page
    /// - Parameters:
    ///   - page: function key's page
    ///   - key: the function key needs update
    ///   - keyboardView: host keyboard view
    func update(page: Page, functionKey key: FunctionKey, in keyboardView: KeyboardView)
    
    /// Return a KeyPopup for keyView
    /// - Parameters:
    ///   - keyView: the reference for popup
    ///   - keyboardView: host keyboard view
    func popup(for keyView: KeyView, in keyboardView: KeyboardView) -> KeyPopup
}
