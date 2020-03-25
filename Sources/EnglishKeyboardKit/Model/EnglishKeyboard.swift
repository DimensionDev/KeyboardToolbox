//
//  EnglishKeyboard.swift
//  
//
//  Created by Cirno MainasuK on 2020-3-25.
//

import Foundation
import KeyboardCore

final public class EnglishKeyboard: Keyboard {
    
    let englishKeyboardDataSource = EnglishKeyboardDataSource()
    
    init() {
        super.init(languageLayout: .en_US)
        
        dataSource = englishKeyboardDataSource
    }
    
}
