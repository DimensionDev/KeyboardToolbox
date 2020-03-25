//
//  QWERTYKeyCode.swift
//  
//
//  Created by Cirno MainasuK on 2020-3-25.
//

import Foundation

public enum QWERTYKeyCode: String, KeyCode {
    
    case q, w, e, r, t, y, u, i, o, p
    case a, s, d, f, g, h, j, k, l
    case z, x, c, v, b, n, m
    
    public var code: String {
        return String(describing: Self.self) + "." + rawValue
    }
    
    public var normal: String {
        return rawValue
    }
    
    public var shift: String {
        return rawValue.uppercased()
    }
    
}

extension QWERTYKeyCode {
    
    public static func keyCodes(forRow row: Int) -> [QWERTYKeyCode] {
        switch row {
        case 0:
            return [.q, .w, .e, .r, .t, .y, .u, .i, .o, .p]
        case 1:
            return [.a, .s, .d, .f, .g, .h, .j, .k, .l]
        case 2:
            return [.z, .x, .c, .v, .b, .n, .m]
        default:
            assertionFailure()
            return []
        }
    }
    
    public static func keyCodes() -> [[QWERTYKeyCode]] {
        return [
            QWERTYKeyCode.keyCodes(forRow: 0),
            QWERTYKeyCode.keyCodes(forRow: 1),
            QWERTYKeyCode.keyCodes(forRow: 2)
        ]
    }
    
    public static func keys(forRow row: Int) -> [Key] {
        switch row {
        case 0:
            let keyCodes: [QWERTYKeyCode] = [.q, .w, .e, .r, .t, .y, .u, .i, .o, .p]
            return keyCodes.map { Key(keyCode: $0) }
        case 1:
            let keyCodes: [QWERTYKeyCode] = [.a, .s, .d, .f, .g, .h, .j, .k, .l]
            return keyCodes.map { Key(keyCode: $0) }
        case 2:
            let keyCodes: [QWERTYKeyCode] = [.z, .x, .c, .v, .b, .n, .m]
            return keyCodes.map { Key(keyCode: $0) }
        default:
            assertionFailure()
            return []
        }
    }
    
}
