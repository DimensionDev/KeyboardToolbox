//
//  EnglishNumberPage.swift
//  
//
//  Created by Cirno MainasuK on 2020-3-25.
//

import Foundation
import KeyboardCore

final class EnglishNumberPage: Page {
    
    // 1234567890
    // -/:;()$&@"
    // .,?!'
    
    let keyCodes: [[KeyCode]] = [
        ArabicNumberKeyCode.allCases,
        [.hyphen_minus, .solidus, .colon, .simicolon, .left_parenthesis, .right_parenthesis, .dollar_sign, .ampersand, .commercial_at, .quotation_mark] as [SymbolKeyCode],
        [KeyboardFunctionKeyCode.shiftSymbol] + ([.full_stop, .comma, .question_mark, .exclamation_mark, .apostrophe] as [SymbolKeyCode]) + [KeyboardFunctionKeyCode.backspace],
        [KeyboardFunctionKeyCode.page, KeyboardFunctionKeyCode.globe, KeyboardFunctionKeyCode.space, KeyboardFunctionKeyCode.return],
    ]
    
    override init() {
        super.init()
        dataSource = self
    }
    
}

// MARK: - PageDataSource
extension EnglishNumberPage: PageDataSource {
    
    func numberOfRows(for page: Page) -> Int {
        return keyCodes.count
    }
    
    func page(_ page: Page, numberOfKeysInRow row: Int) -> Int {
        return keyCodes[row].count
    }
    
    func page(_ page: Page, keyForPageAt indexPath: IndexPath) -> Key {
        let keyCode = keyCodes[indexPath.section][indexPath.row]
        
        if let functionKeyCode = keyCode as? KeyboardFunctionKeyCode {
            return FunctionKey(keyCode: functionKeyCode)
        } else {
            return Key(keyCode: keyCode)
        }
    }
    
}
