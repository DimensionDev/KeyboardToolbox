//
//  KeyboardDataSource.swift
//  
//
//  Created by Cirno MainasuK on 2020-3-25.
//

import Foundation

public protocol KeyboardDataSource: class {
    func numberOfPages() -> Int
    func keyboard(_ keyboard: Keyboard, pageAt index: Int) -> Page
    func nextPage(for keyCode: KeyboardFunctionKeyCode, from page: Page) -> Page
}
