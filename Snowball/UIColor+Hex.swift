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
}