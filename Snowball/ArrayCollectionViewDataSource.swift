//
//  ArrayCollectionViewDataSource.swift
//  Snowball
//
//  Created by James Martinez on 12/3/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

class ArrayCollectionViewDataSource: CollectionViewDataSource {
  var objects: [[AnyObject]]

  // MARK: - Initializers

  init(collectionView: UICollectionView, objects: [[AnyObject]], cellTypes: [UICollectionViewCell.Type]) {
    self.objects = objects
    super.init(collectionView: collectionView, cellTypes: cellTypes)
  }

  // MARK: - CollectionViewDataSource

  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return objects.count
  }

  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return objects[section].count
  }

  override func configureCell(cell: UICollectionViewCell, atIndexPath indexPath: NSIndexPath) {
    cell.configureForObject(objects[indexPath.section][indexPath.row])
  }
}