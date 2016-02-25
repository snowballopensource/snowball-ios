//
//  UIFont+Snowball.swift
//  Snowball
//
//  Created by James Martinez on 2/16/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
  struct SnowballFont {
    static let regularFont: UIFont = {
      if #available(iOS 8.2, *) {
        return UIFont.systemFontOfSize(defaultFontSize, weight: UIFontWeightRegular)
      } else {
        return UIFont(name: "HelveticaNeue", size: defaultFontSize) ?? UIFont()
      }
    }()
    static let mediumFont: UIFont = {
      if #available(iOS 8.2, *) {
        return UIFont.systemFontOfSize(defaultFontSize, weight: UIFontWeightMedium)
      } else {
        return UIFont(name: "HelveticaNeue-Medium", size: defaultFontSize) ?? UIFont()
      }
    }()

    private static let defaultFontSize: CGFloat = 16
  }
}