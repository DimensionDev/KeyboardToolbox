//
//  SymbolKeyCode.swift
//  
//
//  Created by Cirno MainasuK on 2020-3-25.
//

import Foundation

public enum SymbolKeyCode: String, KeyCode {
    
    // - / : ; ( ) $ & @ "
    case hyphen_minus, solidus, colon, simicolon, left_parenthesis, right_parenthesis, dollar_sign, ampersand, commercial_at, quotation_mark
    
    // [ ] { } # % ^ * + =
    case left_square_bracket, right_square_bracket, left_curly_bracket, right_curly_bracket, number_sign, percent_sign, circumflex_accent, asterist, plus_sign, equals_sign
    
    // _ \ | ~ < > € £ ¥ •
    case low_line, reverse_solidus, vertical_line, tilde, less_then_sign, greater_then_sign, euro_sign, pound_sign, yen_sign, bullet
    
    // . , ? ! '
    case full_stop, comma, question_mark, exclamation_mark, apostrophe
    
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

extension SymbolKeyCode {
    
    public var cap: String {
        switch self {
        case .hyphen_minus:         return "-"
        case .solidus:              return "/"
        case .colon:                return ":"
        case .simicolon:            return ";"
        case .left_parenthesis:     return "("
        case .right_parenthesis:    return ")"
        case .dollar_sign:          return "$"
        case .ampersand:            return "&"
        case .commercial_at:        return "@"
        case .quotation_mark:       return "\""
            
        case .full_stop:            return "."
        case .comma:                return ","
        case .question_mark:        return "?"
        case .exclamation_mark:     return "!"
        case .apostrophe:           return "'"
            
        case .left_square_bracket:  return "["
        case .right_square_bracket: return "]"
        case .left_curly_bracket:   return "{"
        case .right_curly_bracket:  return "}"
        case .number_sign:          return "#"
        case .percent_sign:         return "%"
        case .circumflex_accent:    return "^"
        case .asterist:             return "*"
        case .plus_sign:            return "+"
        case .equals_sign:          return "="
            
        case .low_line:             return "_"
        case .reverse_solidus:      return "\\"
        case .vertical_line:        return "|"
        case .tilde:                return "~"
        case .less_then_sign:       return "<"
        case .greater_then_sign:    return ">"
        case .euro_sign:            return "€"
        case .pound_sign:           return "£"
        case .yen_sign:             return "¥"
        case .bullet:               return "•"
        }
    }
    
}
