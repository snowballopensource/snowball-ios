//
//  UIColor+.swift
//  Snowball
//
//  Created by James Martinez on 10/6/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

extension UIColor {
  convenience init(hex: String) {
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    let scanner = NSScanner(string: hex)
    var hexValue: CUnsignedLongLong = 0
    if scanner.scanHexLongLong(&hexValue) {
      red = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
      green = CGFloat((hexValue & 0x00FF00) >> 8) / 255.0
      blue = CGFloat(hexValue & 0x0000FF) / 255.0
    }
    self.init(red: red, green: green, blue: blue, alpha: 1.0)
  }

  class func randomColor() -> UIColor {
    let hue = CGFloat(Float(arc4random_uniform(257)) / 256.0) // 0.0 to 1.0
    return UIColor(hue: hue, saturation: 0.5, brightness: 0.9, alpha: 1.0)
  }

  func hex() -> String {
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    getRed(&red, green: &green, blue: &blue, alpha: nil)
    let redDec = UInt(red * 255)
    let greenDec = UInt(green * 255)
    let blueDec = UInt(blue * 255)
    let hex = String(format: "%02x%02x%02x", redDec, greenDec, blueDec)
    return hex
  }
}