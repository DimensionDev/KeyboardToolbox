//
//  KeyboardViewNormalLayoutSettings.swift
//  
//
//  Created by Cirno MainasuK on 2020-3-25.
//

import UIKit
import KeyboardCore

// TODO: landscape & iPad support
public struct EnglishKeyboardViewLayoutSettings {
    
    public var size: CGSize = .zero
    
    public var preferSmallLowercase: Bool = true
}

// MARK: - KeyboardViewLayoutSettings
extension EnglishKeyboardViewLayoutSettings: KeyboardViewLayoutSettings {
    
    public func keyCapFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: weight)
    }
    
    static func keyCapRegularFont(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .regular)
    }
    static func keyCapLightFont(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .light)
    }
    static func keyCapThinFont(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .thin)
    }
    
    public var isLandscape: Bool {
        let boundsRatio = size.width / size.height
        return boundsRatio >= 2
    }
    
    public var contentInsets: UIEdgeInsets {
        let top: CGFloat = size.width < 375.0 ? 12.0 : 8.0
        let bottom: CGFloat = size.width < 414.0 ? 4.0 : 5.0
        
        return UIEdgeInsets(top: top, left: 0, bottom: bottom, right: 0)
    }
    
    public var minimumLineSpacing: CGFloat {
        // 320 - 375 - 414
        if size.width < 375.0 {
            return 16.0
        } else if size.width < 414.0 {
            return 12.0
        } else {
            return 11.0
        }
    }
    
    public var minimumInteritemSpacing: CGFloat {
        return 6.0
    }
    
    public var bottomShadowHeight: CGFloat {
        return 1.0
    }
    
    public var keyCornerRadius: CGFloat {
        return 5.0
    }
    
}
