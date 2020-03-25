//
//  ArabicNumberKeyCode.swift
//  
//
//  Created by Cirno MainasuK on 2020-3-25.
//

import Foundation

public enum ArabicNumberKeyCode: String, CaseIterable, KeyCode {
    
    // 1 2 3 4 5 6 7 8 9 0
    case one, two, three, four, five, six, seven, eight, nine, zero
    
    public var code: String {
        return String(describing: Self.self) + "." + rawValue
    }
    
    public var normal: String {
        return cap
    }
    
    public var shift: String {
        return cap
    }
    
}

extension ArabicNumberKeyCode {
    
    public var cap: String {
        switch self {
        case .one:      return "1"
        case .two:      return "2"
        case .three:    return "3"
        case .four:     return "4"
        case .five:     return "5"
        case .six:      return "6"
        case .seven:    return "7"
        case .eight:    return "8"
        case .nine:     return "9"
        case .zero:     return "0"
        }
    }
    
}
