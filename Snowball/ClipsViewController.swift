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
    collectionView.backgroundColor = UIColor.blueColor()
    return collectionView
  }()
  var managedCollectionViewManager = ManagedCollectionViewManager()

  // MARK: - UIViewController

  override func loadView() {
    view = collectionView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.dataSource = managedCollectionViewManager
    collectionView.delegate = managedCollectionViewManager

    managedCollectionViewManager.objects = [
      [NSObject(), NSObject(), NSObject()]
    ]
    managedCollectionViewManager.cellTypes = [
      ClipCollectionViewCell.self
    ]
    collectionView.registerCellClass(ClipCollectionViewCell.self)
  }
}
