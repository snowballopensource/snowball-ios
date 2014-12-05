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
  let arrayDataSource: ArrayDataSource = {
    let objects: [[AnyObject]] = [
      [
        "",
        "",
        ""
      ]
    ]
    let cellTypes: [UICollectionViewCell.Type] = [
      ClipCollectionViewCell.self
    ]
    return ArrayDataSource(objects: objects, cellTypes: cellTypes)
  }()

  // MARK: - UIViewController

  override func loadView() {
    view = collectionView
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    collectionView.registerCellClass(ClipCollectionViewCell.self)
    collectionView.dataSource = arrayDataSource
    collectionView.delegate = arrayDataSource
  }
}
