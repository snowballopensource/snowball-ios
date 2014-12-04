//
//  ClipsViewController.swift
//  Snowball
//
//  Created by James Martinez on 12/3/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

class ClipsViewController: UIViewController {

  // MARK: - Properties

  var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
    let flowLayout = collectionView.collectionViewLayout as UICollectionViewFlowLayout
    flowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.minimumLineSpacing = 0
    collectionView.backgroundColor = UIColor.whiteColor()
    return collectionView
  }()
  var managedCollectionViewManager = ManagedCollectionViewManager()

  // MARK: - UIViewController

  override func loadView() {
    view = collectionView
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    managedCollectionViewManager.objects = [
      [NSObject(), NSObject(), NSObject()]
    ]
    managedCollectionViewManager.cellTypes = [
      ClipCollectionViewCell.self
    ]
    collectionView.registerCellClass(ClipCollectionViewCell.self)
    collectionView.dataSource = managedCollectionViewManager
    collectionView.delegate = managedCollectionViewManager
  }
}
