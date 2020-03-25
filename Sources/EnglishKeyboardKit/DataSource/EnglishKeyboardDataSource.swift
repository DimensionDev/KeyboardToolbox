//
//  EnglishKeyboardDataSource.swift
//  
//
//  Created by Cirno MainasuK on 2020-3-25.
//

import Foundation
import KeyboardCore

final public class EnglishKeyboardDataSource: KeyboardDataSource {
    
    let pages: [Page]
    
    public init() {
        let characterPage = EnglishCharacterPage()
        let numberPage = EnglishNumberPage()
        let symbolPage = EnglishSymbolPage()
        
        self.pages = [
            characterPage, numberPage, symbolPage
        ]
    }
    
    public func numberOfPages() -> Int {
        return pages.count
    }
    
    public func keyboard(_ keyboard: Keyboard, pageAt index: Int) -> Page {
        return pages[index]
    }
    
    public func nextPage(for keyCode: KeyboardFunctionKeyCode, from page: Page) -> Page {
        switch keyCode {
        case .page:
            return page is EnglishCharacterPage ? pages[1] : pages[0]
        case .shiftSymbol:
            return pages[2]     // symbol page
        case .shiftNumber:
            return pages[1]     // number page
            
        default:
            assertionFailure()
            return pages[0]
        }
    }
    
}
