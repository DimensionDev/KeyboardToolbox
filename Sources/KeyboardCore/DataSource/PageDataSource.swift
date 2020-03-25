//
//  PageDataSource.swift
//  
//
//  Created by Cirno MainasuK on 2020-3-25.
//

import Foundation

public protocol PageDataSource: class {
    func numberOfRows(for page: Page) -> Int
    func page(_ page: Page, numberOfKeysInRow row: Int) -> Int
    func page(_ page: Page, keyForPageAt indexPath: IndexPath) -> Key
}
