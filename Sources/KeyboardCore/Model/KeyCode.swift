//
//  KeyCode.swift
//  
//
//  Created by Cirno MainasuK on 2020-3-25.
//

import Foundation

public protocol KeyCode {
    var code: String { get }
    
    var normal: String { get }
    var shift: String { get }
}

extension KeyCode {
    public var normal: String { return "" }
    public var shift: String { return "" }
}
