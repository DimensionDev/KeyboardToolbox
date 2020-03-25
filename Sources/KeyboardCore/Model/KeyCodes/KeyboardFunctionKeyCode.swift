//
//  KeyboardFunctionKeyCode.swift
//  
//
//  Created by Cirno MainasuK on 2020-3-25.
//

import UIKit

public enum KeyboardFunctionKeyCode: String, KeyCode {
    
    case any
    
    case shift          // up-arrow. chracter shift
    case shiftNumber    // 123
    case shiftSymbol    // #+=
    case backspace
    case page
    case globe          // change to other keyboard
    case space
    case `return`
    
    public var code: String {
        return String(describing: KeyboardFunctionKeyCode.self) + "." + self.rawValue
    }
    
    public var normal: String {
        switch self {
        case .shiftSymbol:
            return "#+="
        case .shiftNumber:
            return "123"
        case .space:
            return "space"
        case .return:
            return "return"
        default:
            return ""
        }
    }
    
}

extension KeyboardFunctionKeyCode {
    
    public func image(shiftState: ShiftState) -> UIImage? {
        switch self {
        case .shift:
            return UIImage(systemName: "shift")!
        case .backspace:
            return UIImage(systemName: "delete.left")!
        case .page:
            return nil
        case .globe:
            return UIImage(systemName: "globe")!
        case .space:
            return nil
        case .return:
            return nil
        default:
            return nil
        }
    }
    
}
