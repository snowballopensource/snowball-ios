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
      setTitleColor(color.colorWithBrightnessOffset(0.3), forState: UIControlState.Highlighted)
      setTitleColor(color.colorWithBrightnessOffset(0.3), forState: UIControlState.Highlighted | UIControlState.Selected)
    }
  }

  func setImageTintColorWithAutomaticHighlightColor(color: UIColor? = UIColor.whiteColor()) {
    if let color = color {
      setImage(imageView?.image?.imageWithColor(color), forState: UIControlState.Normal)
      setImage(imageView?.image?.imageWithColor(color.colorWithBrightnessOffset(0.2)), forState: UIControlState.Highlighted)
    }
  }
}

private extension UIColor {
  func colorWithBrightnessOffset(offset: CGFloat) -> UIColor {
    if self == UIColor.whiteColor() {
      return UIColor(white: 1.0 - offset, alpha: 1.0)
    }
    if self ==  UIColor.blackColor() {
      return UIColor(white: 0.0 + offset, alpha: 1.0)
    }
    var hue: CGFloat = 0.0
    var saturation: CGFloat = 0.0
    var brightness: CGFloat = 0.0
    getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)
    brightness -= offset
    return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
  }
}

private extension UIImage {
  private func imageWithColor(color: UIColor) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, false, scale)
    let context = UIGraphicsGetCurrentContext()
    CGContextTranslateCTM(context, 0, size.height)
    CGContextScaleCTM(context, 1.0, -1.0)
    CGContextSetBlendMode(context, kCGBlendModeNormal)
    let rect = CGRectMake(0, 0, size.width, size.height)
    CGContextClipToMask(context, rect, CGImage)
    color.setFill()
    CGContextFillRect(context, rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
  }
}