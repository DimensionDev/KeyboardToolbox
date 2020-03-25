//
//  UIUserInterfaceSizeClass.swift
//  EnglishKeyboard
//
//  Created by Cirno MainasuK on 2020-3-25.
//  Copyright © 2020 dimension. All rights reserved.
//

import UIKit

extension UIUserInterfaceSizeClass: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unspecified:  return "unspecified"
        case .compact:      return "compact"
        case .regular:      return "regular"
        @unknown default:   return "@unknown"
        }
    }
}
