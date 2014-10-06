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

  class func size() -> CGSize {
    requireSubclass()
    return CGSizeMake(0.0, 0.0)
  }

  func configureForObject(object: AnyObject) {
    requireSubclass()
  }
}
