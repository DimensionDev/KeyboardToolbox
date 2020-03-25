//
//  File.swift
//  
//
//  Created by Cirno MainasuK on 2020-3-24.
//

import UIKit
import os

public class FunctionKeyView: KeyView {
    
    public private(set) var imageView = UIImageView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _init()
    }
    
    private func _init() {
        addSubview(imageView)
        imageView.frame = bounds
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
    
    deinit {
        os_log("%{public}s[%{public}ld], %{public}s: deinit", ((#file as NSString).lastPathComponent), #line, #function)
        
    }
    
}

extension FunctionKeyView {
    
    public class func backgroundColor(for userInterfaceStyle: UIUserInterfaceStyle, highlight: Bool) -> UIColor {
        if !highlight {
            return userInterfaceStyle == .dark ? UIColor(white: 0.80, alpha: 0.1) : UIColor(red: 159.0/255.0, green: 166.0/255.0, blue: 176.0/255.0, alpha: 1.0)
        } else {
            return userInterfaceStyle == .dark ? UIColor(white: 0.80, alpha: 0.95) : .white
        }
    }
    
}
