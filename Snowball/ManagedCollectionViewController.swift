//
//  ManagedCollectionViewController.swift
//  Snowball
//
//  Created by James Martinez on 10/29/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

class ManagedCollectionViewController: ManagedViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())

  func cellTypeInSection(section: Int) -> UICollectionViewCell.Type {
    requireSubclass()
    return UICollectionViewCell.self
  }

  func configureCell(cell: UICollectionViewCell, atIndexPath indexPath: NSIndexPath) {
    cell.configureForObject(objectsInSection(indexPath.section).objectAtIndex(UInt(indexPath.row)))
  }

  private func registerCells() {
    for i in 0...collectionView.numberOfSections() {
      collectionView.registerClass(cellTypeInSection(i), forCellWithReuseIdentifier: cellTypeInSection(i).identifier)
    }
  }

  // MARK: -

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.frame = view.bounds
    collectionView.backgroundColor = UIColor.whiteColor()
    view.addSubview(collectionView)
    collectionView.dataSource = self
    collectionView.delegate = self
    registerCells()
  }

  // MARK: UICollectionViewDataSource

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return Int(objectsInSection(section).count)
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellTypeInSection(indexPath.section).identifier, forIndexPath: indexPath) as UICollectionViewCell
    configureCell(cell, atIndexPath: indexPath)
    return cell
  }

  // MARK: UICollectionViewDelegateFlowLayout

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return cellTypeInSection(indexPath.section).size()
  }

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
    return 0
  }
}