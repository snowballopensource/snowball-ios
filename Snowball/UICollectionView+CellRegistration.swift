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

  func registerHeaderClass(headerClass: UICollectionReusableView.Type) {
    registerClass(headerClass, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: NSStringFromClass(headerClass))
  }

  func registerFooterClass(footerClass: UICollectionReusableView.Type) {
    registerClass(footerClass, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: NSStringFromClass(footerClass))
  }
}
