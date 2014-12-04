//
//  ManagedCollectionViewManager.swift
//  Snowball
//
//  Created by James Martinez on 12/3/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

class ManagedCollectionViewManager: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

  // MARK: - Properties

  var objects = [[AnyObject]]()
  var cellTypes = [UICollectionViewCell.Type]()

  // MARK: - UICollectionViewDataSource

  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return objects.count
  }

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return objects[section].count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(cellTypes[indexPath.section]),
      forIndexPath: indexPath) as UICollectionViewCell
    cell.configureForObject(objects[indexPath.section][indexPath.row])
    return cell
  }

  // MARK: - UICollectionViewDelegateFlowLayout

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return cellTypes[indexPath.section].size()
  }

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
    minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
    return 0
  }

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
    minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
    return 0
  }
}