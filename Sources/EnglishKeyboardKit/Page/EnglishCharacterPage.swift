//
//  EnglishCharacterPage.swift
//  
//
//  Created by Cirno MainasuK on 2020-3-25.
//

import Foundation
import KeyboardCore

final class EnglishCharacterPage: Page {
    
    // Note: layout
    // qwertyuiop
    // asdfghjkl
    // [shift-upArrow]zxcvbnm[backward]
    // [page-toSymbol][global_optional][space][return]
    
    let keyCodes: [[KeyCode]] = [
        QWERTYKeyCode.keyCodes(forRow: 0),
        QWERTYKeyCode.keyCodes(forRow: 1),
        [KeyboardFunctionKeyCode.shift] + QWERTYKeyCode.keyCodes(forRow: 2) + [KeyboardFunctionKeyCode.backspace],
        [KeyboardFunctionKeyCode.page, KeyboardFunctionKeyCode.globe, KeyboardFunctionKeyCode.space, KeyboardFunctionKeyCode.return],
    ]
    
    override init() {
        super.init()
        dataSource = self
    }
    
}

// MARK: - PageDataSource
extension EnglishCharacterPage: PageDataSource {
    
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
