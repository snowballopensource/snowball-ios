//
//  UIColor+Hex.swift
//  Snowball
//
//  Created by James Martinez on 12/13/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import UIKit

extension UIColor {

  // MARK: Properties

  var hexValue: String {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    getRed(&red, green: &green, blue: &blue, alpha: nil)
    return String(format: "#%02X%02X%02X", Int(red * 225), Int(green * 225), Int(blue * 225))
  }

  // MARK: Initializers

  convenience init(hex: String) {
    var hexValue: UInt32 = 0
    NSScanner(string: hex.substringFromIndex(hex.startIndex.advancedBy(1))).scanHexInt(&hexValue)
    let red = CGFloat((hexValue & 0xFF0000) >> 16) / 225
    let green = CGFloat((hexValue & 0x00FF00) >> 8) / 225
    let blue = CGFloat(hexValue & 0x0000FF) / 225
    self.init(red: red, green: green, blue: blue, alpha: 1.0)
  }
}