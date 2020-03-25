//
//  KeyView.swift
//  
//
//  Created by Cirno MainasuK on 2020-3-24.
//

import UIKit
import os

public class KeyView: UIControl {
    
    public var key: Key = Key(keyCode: NoKeyCapKeyCode.any)
    
    var popup: KeyPopup?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _init()
    }
    
    private func _init() { }
    
    deinit {
        os_log("%{public}s[%{public}ld], %{public}s: deinit", ((#file as NSString).lastPathComponent), #line, #function)
    }
    
}

extension KeyView {
    
    public class func foregroundColor(for userInterfaceStyle: UIUserInterfaceStyle) -> UIColor {
        return userInterfaceStyle == .dark ? .white : .black
    }
    
    public class func backgroundColor(for userInterfaceStyle: UIUserInterfaceStyle) -> UIColor {
        return userInterfaceStyle == .dark ? UIColor.white.withAlphaComponent(0.17) : .white
    }
    
    public class func shadowColor(for userInterfaceStyle: UIUserInterfaceStyle) -> UIColor {
        return userInterfaceStyle == .light ? .systemGray : .black
    }
    
}
