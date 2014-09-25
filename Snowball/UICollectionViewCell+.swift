//
//  UICollectionViewCell+.swift
//  Snowball
//
//  Created by James Martinez on 9/24/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

extension UICollectionViewCell {
  class var identifier: String {
    return NSStringFromClass(self)
  }

  func configureForObject(object: AnyObject) {
    requireSubclass()
  }
}
