//
//  UITableViewCell.swift
//  Snowball
//
//  Created by James Martinez on 9/22/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

extension UITableViewCell {
  class var identifier: String {
    return NSStringFromClass(self)
  }

  func configureForObject(object: AnyObject) {
    requireSubclass()
  }
}
