//
//  NoKeyCapKeyCode.swift
//  
//
//  Created by Cirno MainasuK on 2020-3-25.
//

import Foundation

// Key stub for debug
public enum NoKeyCapKeyCode: String, KeyCode {
    
    case any
    
    public var code: String {
        return String(describing: NoKeyCapKeyCode.self) + "." + self.rawValue
    }
    
}
