//
//  Key.swift
//  
//
//  Created by Cirno MainasuK on 2020-3-25.
//

import UIKit
import CoreGraphics

open class Key {
    
    public let keyCode: KeyCode
    public var backgroundRect: CGRect = .zero      // without bottom shadow part
    
    public init(keyCode: KeyCode = NoKeyCapKeyCode.any) {
        self.keyCode = keyCode
    }
    
}

extension Key: Hashable {
    
    public static func == (lhs: Key, rhs: Key) -> Bool {
        return lhs.keyCode.code == rhs.keyCode.code
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(keyCode.code)
    }
    
}
