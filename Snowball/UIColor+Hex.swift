//
//  UIColor+Hex.swift
//  Snowball
//
//  Created by James Martinez on 8/30/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
  var hexValue: String {
    let colorRef = CGColorGetComponents(CGColor)

    let red = Float(colorRef[0])
    let green = Float(colorRef[1])
    let blue = Float(colorRef[2])

    return String(format: "#%02lX%02lX%02lX", lroundf(red * 255), lroundf(green * 255), lroundf(blue * 255))
  }

  convenience init(hex: String) {
    var rgb: UInt32 = 0
    let scanner = NSScanner(string: hex)
    scanner.scanLocation = 1 // Ignore the leading '#'
    scanner.scanHexInt(&rgb)
    self.init(
      red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(rgb & 0x0000FF) / 255.0,
      alpha: 1
    )
  }
}