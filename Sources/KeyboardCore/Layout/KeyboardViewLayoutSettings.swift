//
//  KeyboardViewLayoutSettings.swift
//  
//
//  Created by Cirno MainasuK on 2020-3-25.
//

import UIKit

public protocol KeyboardViewLayoutSettings {
    // Input
    var size: CGSize { get set }
    
    // Style
    var preferSmallLowercase: Bool { get set }
    
    // Layout
    var isLandscape: Bool { get }
    var contentInsets: UIEdgeInsets { get }
    var minimumLineSpacing: CGFloat { get }
    var minimumInteritemSpacing: CGFloat { get }
    var bottomShadowHeight: CGFloat { get }
    var keyCornerRadius: CGFloat { get }
    
    func keyCapFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont
}

extension KeyboardViewLayoutSettings {
    
    /// keyboard size for width
    /// - Parameter width: 320 / 375 / 414
    /// - Parameter scale: UIScreen.scale 2.0 or 3.0
    public static func keyboardHeight(for width: CGFloat, in scale: CGFloat) -> CGFloat {
        if scale < 3.0 {
            return width > 320.0 ? 216 : 226
        } else {
            return width < 414.0 ? 216 : 226
        }
    }
    
}
