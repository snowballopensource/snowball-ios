//
//  TimelineCollectionView.swift
//  Snowball
//
//  Created by James Martinez on 12/10/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import UIKit

class TimelineCollectionView: UICollectionView {

  // MARK: UICollectionView

  init() {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .Horizontal
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    layout.itemSize = ClipCollectionViewCell.defaultSize
    super.init(frame: CGRectZero, collectionViewLayout: layout)
    showsHorizontalScrollIndicator = false
    backgroundColor = UIColor.purpleColor()
    registerClass(ClipCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(ClipCollectionViewCell))
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}