//
//  Keyboard.swift
//  
//
//  Created by Cirno MainasuK on 2020-3-25.
//

import Foundation

open class Keyboard {
    public let languageLayout: LanguageLayout
    weak open var dataSource: KeyboardDataSource?
    
    public init(languageLayout: LanguageLayout = .en_US) {
        self.languageLayout = languageLayout
    }
}

// MARK: - Hashable
extension Keyboard: Hashable {
    
    public static func == (lhs: Keyboard, rhs: Keyboard) -> Bool {
        return lhs.languageLayout == rhs.languageLayout
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(languageLayout)
    }
    
}
