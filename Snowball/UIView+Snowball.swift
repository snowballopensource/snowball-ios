//
//  UIView+Snowball.swift
//  Snowball
//
//  Created by James Martinez on 1/13/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import UIKit

extension UIView {
  func showSnowballStyleBorderWithColor(color: UIColor) {
    layer.cornerRadius = 20
    layer.borderColor = color.CGColor
    layer.borderWidth = 2
  }
}