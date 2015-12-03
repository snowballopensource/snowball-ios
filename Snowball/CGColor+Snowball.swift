//
//  CGColor+Snowball.swift
//  Snowball
//
//  Created by James Martinez on 12/3/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import CoreGraphics
import UIKit

extension CGColor {
  struct SnowballColor {
    static var rainbowColors = [
      UIColor(red: 246 / 255.0, green: 245 / 255.0, blue: 23 / 255.0, alpha: 1.0).CGColor,
      UIColor(red: 83 / 255.0, green: 253 / 255.0, blue: 143 / 255.0, alpha: 1.0).CGColor,
      UIColor(red: 81 / 255.0, green: 213 / 255.0, blue: 236 / 255.0, alpha: 1.0).CGColor,
      UIColor(red: 224 / 255.0, green: 81 / 255.0, blue: 236 / 255.0, alpha: 1.0).CGColor
    ]
  }
}