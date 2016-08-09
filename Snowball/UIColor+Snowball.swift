//
//  UIColor+Snowball.swift
//  Snowball
//
//  Created by James Martinez on 8/8/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import UIKit

extension UIColor {
  struct SnowballColor {
    static func randomColor() -> UIColor {
      let hue = CGFloat(Float(arc4random_uniform(257)) / 256.0) // 0.0 to 1.0
      return UIColor(hue: hue, saturation: 0.6, brightness: 0.9, alpha: 1.0)
    }
  }
}