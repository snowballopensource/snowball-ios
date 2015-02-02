//
//  UITextField+Snowball.swift
//  Snowball
//
//  Created by James Martinez on 1/13/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import UIKit

extension UITextField {
  func alignLeft(insetWidth: CGFloat = 20) {
    contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
    // Since a UITextField does not have `contentEdgeInsets`
    // like a button does, create a `UIView` of the inset width.
    let insetView = UIView(frame: CGRect(x: 0, y: 0, width: insetWidth, height: bounds.size.height))
    insetView.backgroundColor = UIColor.clearColor()
    leftViewMode = UITextFieldViewMode.Always
    leftView = insetView
  }
}
