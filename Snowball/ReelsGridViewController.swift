//
//  ReelsGridViewController.swift
//  Snowball
//
//  Created by James Martinez on 9/24/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class ReelsGridViewController: ManagedCollectionViewController {
  private let topView = TopMediaView()
  private var scrolling = false

  // MARK: -

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.registerClass(ReelCollectionViewCell.self, forCellWithReuseIdentifier: ReelCollectionViewCell.identifier)
    let cameraViewController = CameraViewController()
    addChildViewController(cameraViewController)
    topView.cameraView = cameraViewController.view as? CameraView
    view.addSubview(topView)
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    layout(topView) { (topView) in
      topView.top == topView.superview!.top
      topView.bottom == topView.top + Float(UIScreen.mainScreen().bounds.width)
      topView.left == topView.superview!.left
      topView.right == topView.superview!.right
    }
    layout(collectionView, topView) { (collectionView, topView) in
      collectionView.top == topView.bottom
      collectionView.bottom == collectionView.superview!.bottom
      collectionView.left == collectionView.superview!.left
      collectionView.right == collectionView.superview!.right
    }
  }

  // MARK: ManagedViewController

  override func objects() -> RLMArray {
    return Reel.allObjects()
  }

  override func reloadData() {
    API.getReelStream { (error) in
      if error != nil { error?.display(); return }
      self.collectionView.reloadData()
    }
  }

  // MARK: ManagedCollectionViewController

  override func cellType() -> UICollectionViewCell.Type {
    return ReelCollectionViewCell.self
  }

  override func configureCell(cell: UICollectionViewCell, atIndexPath indexPath: NSIndexPath) {
    let reelCell = cell as ReelCollectionViewCell
    reelCell.configureForObject(objects().objectAtIndex(UInt(indexPath.row)))
    if !scrolling {
      reelCell.startPlayback()
    }
  }

  // MARK: UICollectionViewDelegateFlowLayout

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return ReelCollectionViewCell.size
  }

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
    return 0
  }

  // MARK: UICollectionViewDelegate

  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let reelCell = collectionView.cellForItemAtIndexPath(indexPath) as ReelCollectionViewCell
    let reel = objects().objectAtIndex(UInt(indexPath.row)) as Reel
    reelCell.showPlaybackIndicatorView()
    var videoURLs: [NSURL] = []
    for clip in reel.clips() {
      let clipToPlay = clip as Clip
      videoURLs.append(NSURL(string: clipToPlay.videoURL))
    }
    topView.playerView.playVideoURLs(videoURLs) {
      reelCell.hidePlaybackIndicatorView()
    }
  }

  // MARK: UIScrollViewDelegate

  func scrollViewWillBeginDragging(scrollView: UIScrollView) {
    scrolling = true
    for cell in collectionView.visibleCells() {
      let reelCell = cell as ReelCollectionViewCell
      reelCell.pausePlayback()
    }
  }

  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    scrolling = false
    for cell in collectionView.visibleCells() {
      let reelCell = cell as ReelCollectionViewCell
      reelCell.startPlayback()
    }
  }
}