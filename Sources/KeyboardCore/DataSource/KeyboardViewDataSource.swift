//
//  KeyboardViewDataSource.swift
//  
//
//  Created by Cirno MainasuK on 2020-3-25.
//

import Foundation

public protocol KeyboardViewDataSource: class {
    func numberOfKeyboard() -> Int
    func keyboardView(_ keyboardView: KeyboardView, keyboardAt index: Int) -> Keyboard
}
