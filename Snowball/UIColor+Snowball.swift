//
//  UIColor+Snowball.swift
//  Snowball
//
//  Created by James Martinez on 12/5/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

extension UIColor {
  struct SnowballColor {
    static func randomColor() -> UIColor {
      let hue = CGFloat(Float(arc4random_uniform(257)) / 256.0) // 0.0 to 1.0
      return UIColor(hue: hue, saturation: 0.5, brightness: 0.9, alpha: 1.0)
    }
  }
}