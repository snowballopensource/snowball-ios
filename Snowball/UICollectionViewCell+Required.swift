//
//  UICollectionViewCell+Required.swift
//  Snowball
//
//  Created by James Martinez on 12/4/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

extension UICollectionViewCell {

  // Since UICollectionViewCell is a subclass of UICollectionReuseableView,
  // this method is taken care of in that extension.
  // TODO: turn these methods into a protocol
  override class func size() -> CGSize {
    return super.size()
  }

  func configureForObject(object: AnyObject) {
    requireSubclass()
  }
}