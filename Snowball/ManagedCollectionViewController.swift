//
//  ManagedCollectionViewController.swift
//  Snowball
//
//  Created by James Martinez on 9/24/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

class ManagedCollectionViewController: ManagedViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())

  func cellType() -> UICollectionViewCell.Type {
    requireSubclass()
    return UICollectionViewCell.self
  }

  func configureCell(cell: UICollectionViewCell, atIndexPath indexPath: NSIndexPath) {
    cell.configureForObject(objectsInSection(indexPath.section).objectAtIndex(UInt(indexPath.row)))
  }

  // MARK: -

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.backgroundColor = UIColor.whiteColor()
    view.addSubview(collectionView)
    collectionView.dataSource = self
    collectionView.delegate = self
  }

  override func viewWillLayoutSubviews() {
    collectionView.frame = view.bounds
  }

  // MARK: UICollectionViewDataSource

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return Int(objectsInSection(section).count)
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellType().identifier, forIndexPath: indexPath) as UICollectionViewCell
    configureCell(cell, atIndexPath: indexPath)
    return cell
  }

  // MARK: UICollectionViewDelegateFlowLayout

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return cellType().size()
  }

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
    return 0
  }
}
