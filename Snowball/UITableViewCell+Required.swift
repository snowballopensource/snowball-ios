//
//  UITableViewCell+Required.swift
//  Snowball
//
//  Created by James Martinez on 1/27/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import UIKit

extension UITableViewCell {
  class func height() -> CGFloat {
    requireSubclass()
    return 0
  }

  func configureForObject(object: AnyObject) {
    requireSubclass()
  }
}

