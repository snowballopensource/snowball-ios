//
//  ClipsViewController.swift
//  Snowball
//
//  Created by James Martinez on 12/3/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

class ClipsViewController: UIViewController, UICollectionViewDelegateFlowLayout {
  var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
    let flowLayout = collectionView.collectionViewLayout as UICollectionViewFlowLayout
    flowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.minimumLineSpacing = 0
    flowLayout.footerReferenceSize = AddClipCollectionReuseableView.size()
    collectionView.backgroundColor = UIColor.whiteColor()
    return collectionView
  }()
  let collectionViewDataSource: ClipsDataSource = {
    let objects: [[AnyObject]] = [
      Clip.findAll(context: CoreDataStack.defaultStack.mainQueueManagedObjectContext)
    ]
    let cellTypes: [UICollectionViewCell.Type] = [
      ClipCollectionViewCell.self
    ]
    return ClipsDataSource(objects: objects, cellTypes: cellTypes)
  }()

  // MARK: - UIViewController

  override func loadView() {
    view = collectionView
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    collectionView.registerCellClass(ClipCollectionViewCell.self)
    collectionView.registerFooterClass(AddClipCollectionReuseableView.self)
    collectionView.dataSource = collectionViewDataSource
    collectionView.delegate = self
  }

  // MARK: - UICollectionViewDelegateFlowLayout

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
      return collectionViewDataSource.cellTypes[indexPath.section].size()
  }
}

class ClipsDataSource: ArrayDataSource {

  // MARK: - UICollectionViewDataSource

  func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
    atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    let supplementaryView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter,
      withReuseIdentifier: NSStringFromClass(AddClipCollectionReuseableView), forIndexPath: indexPath) as AddClipCollectionReuseableView
    return supplementaryView
  }

}
