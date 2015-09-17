//
//  UIButton+Snowball.swift
//  Snowball
//
//  Created by James Martinez on 1/13/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import UIKit

extension UIButton {
  func alignLeft(insetWidth insetWidth: CGFloat = 0) {
    contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
    contentEdgeInsets = UIEdgeInsets(top: 0, left: insetWidth, bottom: 0, right: 0)
  }
}
