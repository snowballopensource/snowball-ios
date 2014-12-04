//
//  ClipCollectionViewCell.swift
//  Snowball
//
//  Created by James Martinez on 12/4/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

class ClipCollectionViewCell: UICollectionViewCell {

  // MARK: - UICollectionViewCell+Required

  override class func size() -> CGSize {
    return CGSize(width: 20, height: 20)
  }

  override func configureForObject(object: AnyObject) {
    contentView.backgroundColor = UIColor.redColor()
  }
}
