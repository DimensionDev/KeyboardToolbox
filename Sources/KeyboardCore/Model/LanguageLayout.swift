//
//  LanguageLayout.swift
//  
//
//  Created by Cirno MainasuK on 2020-3-25.
//

import Foundation

public enum LanguageLayout: String, CaseIterable {
    case en_US
}

extension LanguageLayout: CustomStringConvertible {
    public var description: String {
        return self.rawValue
    }
}
