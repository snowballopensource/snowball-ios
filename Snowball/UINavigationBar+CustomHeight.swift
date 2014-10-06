//
//  UINavigationBar+CustomHeight.swift
//  Snowball
//
//  Created by James Martinez on 10/6/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKIt

extension UINavigationBar {
  override public func sizeThatFits(size: CGSize) -> CGSize {
    // Since we are hiding the status bar (20px), we add them to the height of the bar.
    return CGSizeMake(frame.size.width, 64)
  }
}