//
//  UICollectionReusableView+Required.swift
//  Snowball
//
//  Created by James Martinez on 12/5/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

extension UICollectionReusableView {
  class func size() -> CGSize {
    requireSubclass()
    return CGSizeZero
  }

  func configureForObject(object: AnyObject) {
    requireSubclass()
  }
}
