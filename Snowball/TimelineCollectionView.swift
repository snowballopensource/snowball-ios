//
//  TimelineCollectionView.swift
//  Snowball
//
//  Created by James Martinez on 12/10/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import UIKit

class TimelineCollectionView: UICollectionView {

  // MARK: Properties

  var timelineDelegate: TimelineCollectionViewDelegate?

  private let leftSwipeGestureRecognizer: UISwipeGestureRecognizer = {
    let gestureRecognizer = UISwipeGestureRecognizer()
    gestureRecognizer.direction = .Left
    return gestureRecognizer
  }()

  private let rightSwipeGestureRecognizer: UISwipeGestureRecognizer = {
    let gestureRecognizer = UISwipeGestureRecognizer()
    gestureRecognizer.direction = .Right
    return gestureRecognizer
  }()

  // MARK: UICollectionView

  init() {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .Horizontal
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    layout.itemSize = ClipCollectionViewCell.defaultSize
    super.init(frame: CGRectZero, collectionViewLayout: layout)
    showsHorizontalScrollIndicator = false
    backgroundColor = UIColor.whiteColor()
    registerClass(ClipCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(ClipCollectionViewCell))

    addGestureRecognizer(leftSwipeGestureRecognizer)
    leftSwipeGestureRecognizer.addTarget(self, action: "leftSwipeGestureRecognizerSwiped")

    addGestureRecognizer(rightSwipeGestureRecognizer)
    rightSwipeGestureRecognizer.addTarget(self, action: "rightSwipeGestureRecognizerSwiped")
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Private

  @objc private func leftSwipeGestureRecognizerSwiped() {
    if !scrollEnabled {
      timelineDelegate?.timelineCollectionViewSwipedLeft(self)
    }
  }

  @objc private func rightSwipeGestureRecognizerSwiped() {
    if !scrollEnabled {
      timelineDelegate?.timelineCollectionViewSwipedRight(self)
    }
  }
}

// MARK: - TimelineCollectionViewDelegate

protocol TimelineCollectionViewDelegate {
  func timelineCollectionViewSwipedLeft(collectionView: TimelineCollectionView)
  func timelineCollectionViewSwipedRight(collectionView: TimelineCollectionView)
}