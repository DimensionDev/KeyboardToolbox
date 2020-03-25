//
//  EnglishSymbolPage.swift
//  
//
//  Created by Cirno MainasuK on 2020-3-25.
//

import Foundation
import KeyboardCore

final class EnglishSymbolPage: Page {
    
    // []{}#%^*+=
    // _\|~<>€£¥•
    // .,?!'
    
    let keyCodes: [[KeyCode]] = [
        [.left_square_bracket, .right_square_bracket, .left_curly_bracket, .right_curly_bracket, .number_sign, .percent_sign, .circumflex_accent, .asterist, .plus_sign, .equals_sign] as [SymbolKeyCode],
        [.low_line, .reverse_solidus, .vertical_line, .tilde, .less_then_sign, .greater_then_sign, .euro_sign, .pound_sign, .yen_sign, .bullet] as [SymbolKeyCode],
        [KeyboardFunctionKeyCode.shiftNumber] + ([.full_stop, .comma, .question_mark, .exclamation_mark, .apostrophe] as [SymbolKeyCode]) + [KeyboardFunctionKeyCode.backspace],
        [KeyboardFunctionKeyCode.page, KeyboardFunctionKeyCode.globe, KeyboardFunctionKeyCode.space, KeyboardFunctionKeyCode.return],
    ]
    
    override init() {
        super.init()
        dataSource = self
    }
    
}

// MARK: - PageDataSource
extension EnglishSymbolPage: PageDataSource {
    
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
