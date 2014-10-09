//
//  UIButton+Color.swift
//  Snowball
//
//  Created by James Martinez on 10/6/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

extension UIButton {
  func setTitleColorWithAutomaticHighlightColor(color: UIColor? = UIColor.whiteColor()) {
    if let color = color {
      setTitleColor(color, forState: UIControlState.Normal)
      setTitleColor(color.colorWithOffset(0.3), forState: UIControlState.Highlighted)
      setTitleColor(color.colorWithOffset(0.3), forState: UIControlState.Highlighted | UIControlState.Selected)
    }
  }
}

private extension UIColor {
  func colorWithOffset(offset: CGFloat) -> UIColor {
    if self == UIColor.whiteColor() {
      return UIColor(white: 1.0 - offset, alpha: 1.0)
    }
    var hue: CGFloat = 0.0
    var saturation: CGFloat = 0.0
    var brightness: CGFloat = 0.0
    getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)
    brightness -= offset
    return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
  }
}