//
//  Page.swift
//  
//
//  Created by Cirno MainasuK on 2020-3-25.
//

import os
import UIKit

open class Page {
    public var keys: [[Key]] = []
    public var keyPlane: [Key: KeyView] = [:]
    public var needsInputModeSwitchKey: Bool = true
    open weak var dataSource: PageDataSource?
    
    public var shiftKey: FunctionKey?
    public var backspaceKey: FunctionKey?
    public var pageKey: FunctionKey?
    public var globeKey: FunctionKey?
    public var spaceKey: FunctionKey?
    public var returnKey: FunctionKey?
    
    public init() { }
    
    deinit {
        os_log("%{public}s[%{public}ld], %{public}s: deinit", ((#file as NSString).lastPathComponent), #line, #function)
    }
}

extension Page {
    func reloadData() {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)
        
        reset()
        
        guard let dataSource = self.dataSource else {
            os_log("%{public}s[%{public}ld], %{public}s: try reloadData but not found dataSource", ((#file as NSString).lastPathComponent), #line, #function)
            return
        }
        
        var keys: [[Key]] = []
        let numberOfRows = dataSource.numberOfRows(for: self)
        for row in 0..<numberOfRows {
            let numberOfKeysInRow = dataSource.page(self, numberOfKeysInRow: row)
            let keysInSection = (0..<numberOfKeysInRow).map { column in
                return dataSource.page(self, keyForPageAt: IndexPath(row: column, section: row))
            }
            keys.append(keysInSection)
        }
        
        self.keys = keys
        
        for row in keys {
            for key in row {
                guard let key = key as? FunctionKey,
                    let keyCode = key.keyCode as? KeyboardFunctionKeyCode else {
                        continue
                }
                
                switch keyCode {
                case .shift:        self.shiftKey = key
                case .backspace:    self.backspaceKey = key
                case .globe:        self.globeKey = key
                case .space:        self.spaceKey = key
                case .return:       self.returnKey = key
                default:            continue
                }
            }
        }
        
        #if DEBUG
        let descritpion: String = {
            return keys.map { keySection in return keySection.map { key in key.keyCode.code }.joined(separator: " ") }
                .joined(separator: "\n")
        }()
        os_log("%{public}s[%{public}ld], %{public}s: load\n----- Page -----\n%s\n----------------", ((#file as NSString).lastPathComponent), #line, #function, descritpion)
        #endif
        
    }
}

extension Page {
    
    private func reset() {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)
        
        keys = []
    }
    
}

extension Page: Hashable {
    
    public static func == (lhs: Page, rhs: Page) -> Bool {
        return lhs.keys == rhs.keys
    }
    
    public func hash(into hasher: inout Hasher) {
        for row in keys {
            for key in row {
                hasher.combine(key.keyCode.code)
            }
        }
    }
    
}
