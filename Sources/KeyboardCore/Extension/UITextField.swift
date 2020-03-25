//
//  UITextField.swift
//  
//
//  Created by Cirno MainasuK on 2020-3-25.
//

import UIKit

extension UITextField: UITextDocumentProxy {
    
    public var documentContextBeforeInput: String? {
        guard let selectedTextRange = selectedTextRange,
            let range = textRange(from: beginningOfDocument, to: selectedTextRange.start) else {
                return nil
        }
        
        return text(in: range)
    }
    
    public var documentContextAfterInput: String? {
        guard let selectedTextRange = selectedTextRange,
            let range = textRange(from: selectedTextRange.end, to: endOfDocument) else {
                return nil
        }
        
        return text(in: range)
    }
    
    public var selectedText: String? {
        guard let selectedTextRange = selectedTextRange else {
            return nil
        }
        
        return text(in: selectedTextRange)
    }
    
    // TODO: not implement yet
    public var documentInputMode: UITextInputMode? {
        return nil
    }
    
    // TODO: not implement yet
    public var documentIdentifier: UUID {
        return UUID()
    }
    
    // TODO: not implement yet
    public func adjustTextPosition(byCharacterOffset offset: Int) {
        
    }
    
}
