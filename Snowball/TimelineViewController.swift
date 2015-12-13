//
//  TimelineViewController.swift
//  Snowball
//
//  Created by James Martinez on 12/10/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class TimelineViewController: ViewController {

  // MARK: Properties

  let clips = Clip.findAll()
  let timelineCollectionView = TimelineCollectionView()

  // MARK: ViewController

  override func setupSubviews() {
    super.setupSubviews()

    view.addSubview(timelineCollectionView)
    constrain(timelineCollectionView) { timelineCollectionView in
      timelineCollectionView.left == timelineCollectionView.superview!.left
      timelineCollectionView.top == timelineCollectionView.superview!.centerY
      timelineCollectionView.right == timelineCollectionView.superview!.right
      timelineCollectionView.bottom == timelineCollectionView.superview!.bottom
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    timelineCollectionView.dataSource = self
  }
}

// MARK: - UICollectionViewDataSource
extension TimelineViewController: UICollectionViewDataSource {

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return clips.count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(ClipCollectionViewCell), forIndexPath: indexPath) as! ClipCollectionViewCell
    let clip = clips[indexPath.item] as! Clip
    cell.configueForClip(clip)
    return cell
  }
}