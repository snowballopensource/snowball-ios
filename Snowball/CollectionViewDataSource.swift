//
//  CollectionViewDataSource.swift
//  Snowball
//
//  Created by James Martinez on 12/6/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

class CollectionViewDataSource: NSObject, UICollectionViewDataSource {
  var cellTypes = [UICollectionViewCell.Type]()

  // MARK: - Initializers

  init(cellTypes: [UICollectionViewCell.Type]) {
    self.cellTypes = cellTypes
  }

  // MARK: - UICollectionViewDataSource

  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    requireSubclass()
    return 0
  }

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    requireSubclass()
    return 0
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(cellTypes[indexPath.section]),
      forIndexPath: indexPath) as UICollectionViewCell
    configureCell(cell, atIndexPath: indexPath)
    return cell
  }

  // MARK: CollectionViewDataSource

  func configureCell(cell: UICollectionViewCell, atIndexPath indexPath: NSIndexPath) {
    requireSubclass()
  }
}