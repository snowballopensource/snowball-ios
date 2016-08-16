//
//  TimelineCollectionView.swift
//  Snowball
//
//  Created by James Martinez on 8/8/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import UIKit

class TimelineCollectionView: UICollectionView {

  init() {
    let collectionViewLayout = TimelineCollectionViewFlowLayout()
    super.init(frame: CGRectZero, collectionViewLayout: collectionViewLayout)

    registerClass(ClipCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(ClipCollectionViewCell))

    backgroundColor = UIColor.whiteColor()
    showsHorizontalScrollIndicator = false
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK - TimelineCollectionViewFlowLayout
class TimelineCollectionViewFlowLayout: UICollectionViewFlowLayout {

  var delegate: TimelineCollectionViewFlowLayoutDelegate?
  private var updateItems = [UICollectionViewUpdateItem]()

  override init() {
    super.init()
    scrollDirection = .Horizontal
    minimumInteritemSpacing = 0
    minimumLineSpacing = 0
    itemSize = ClipCollectionViewCell.defaultSize
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func prepareForCollectionViewUpdates(updateItems: [UICollectionViewUpdateItem]) {
    super.prepareForCollectionViewUpdates(updateItems)
    self.updateItems = updateItems
  }

  override func finalizeCollectionViewUpdates() {
    super.finalizeCollectionViewUpdates()
    delegate?.timelineCollectionViewFlowLayout(self, willFinalizeCollectionViewUpdates: updateItems)
    updateItems.removeAll()
  }
}

// MARK: - TimelineCollectionViewFlowLayoutDelegate
protocol TimelineCollectionViewFlowLayoutDelegate {
  func timelineCollectionViewFlowLayout(layout: TimelineCollectionViewFlowLayout, willFinalizeCollectionViewUpdates updates: [UICollectionViewUpdateItem])
}