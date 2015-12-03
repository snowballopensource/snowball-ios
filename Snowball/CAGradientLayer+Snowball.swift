//
//  CAGradientLayer+Snowball.swift
//  Snowball
//
//  Created by James Martinez on 12/3/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import Foundation
import QuartzCore

extension CAGradientLayer {
  static func snowballRainbowGradient() -> CAGradientLayer {
    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = CGColor.SnowballColor.rainbowColors
    gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
    gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
    return gradientLayer
  }
}