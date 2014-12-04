//
//  UICollectionView+CellRegistration.swift
//  Snowball
//
//  Created by James Martinez on 12/4/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

extension UICollectionView {
  func registerCellClass(cellClass: UICollectionViewCell.Type) {
    registerClass(cellClass, forCellWithReuseIdentifier: NSStringFromClass(cellClass))
  }
}
