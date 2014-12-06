//
//  ArrayDataSource.swift
//  Snowball
//
//  Created by James Martinez on 12/3/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

class ArrayDataSource: NSObject, UICollectionViewDataSource {
  var objects = [[AnyObject]]()
  var cellTypes = [UICollectionViewCell.Type]()

  // MARK: - Initializers

  init(objects: [[AnyObject]], cellTypes: [UICollectionViewCell.Type]) {
    self.objects = objects
    self.cellTypes = cellTypes
  }

  // MARK: - UITableView

  // MARK: - UITableViewDataSource
  // TODO: write table view data source code

  // MARK: - UICollectionView

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
}