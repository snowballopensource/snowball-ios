//
//  UIColor+Snowball.swift
//  Snowball
//
//  Created by James Martinez on 2/7/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
  struct SnowballColor {
    static var lightGrayColor = UIColor(colorLiteralRed: 204/255.0, green: 204/255.0, blue: 204/255.0, alpha: 1)
    static var blueColor = UIColor(red: 143 / 255.0, green: 236 / 255.0, blue: 255 / 255.0, alpha: 1.0)
    static var randomColor: UIColor {
      let hue = CGFloat(Float(arc4random_uniform(257)) / 256.0) // 0.0 to 1.0
      return UIColor(hue: hue, saturation: 0.6, brightness: 0.9, alpha: 1.0)
    }
  }
}