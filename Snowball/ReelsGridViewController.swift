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
  private let friendsButton = UIButton()
  private var scrolling = false
  private var reelPlayerViewController: ReelPlayerViewController? {
    get {
      for childViewController in childViewControllers {
        if childViewController is ReelPlayerViewController {
          return childViewController as? ReelPlayerViewController
        }
      }
      return nil
    }
  }

  func switchToFriendsNavigationController() {
    switchToNavigationController(FriendsNavigationController())
  }

  // MARK: -

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.registerClass(ReelCollectionViewCell.self, forCellWithReuseIdentifier: ReelCollectionViewCell.identifier)
    let cameraViewController = CameraViewController()
    addChildViewController(cameraViewController)
    topView.cameraView = cameraViewController.view as? CameraView
    topView.addFullViewSubview(topView.cameraView!)
    let reelPlayerViewController = ReelPlayerViewController()
    addChildViewController(reelPlayerViewController)
    topView.playerView = reelPlayerViewController.view as? PlayerView
    topView.addFullViewSubview(topView.playerView!)
    view.addSubview(topView)

    friendsButton.backgroundColor = UIColor.purpleColor()
    friendsButton.addTarget(self, action: "switchToFriendsNavigationController", forControlEvents: UIControlEvents.TouchUpInside)
    topView.addSubview(friendsButton)
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    layout(topView) { (topView) in
      topView.top == topView.superview!.top
      topView.bottom == topView.top + Float(UIScreen.mainScreen().bounds.width)
      topView.left == topView.superview!.left
      topView.right == topView.superview!.right
    }
    layout(friendsButton) { (friendsButton) in
      friendsButton.top == friendsButton.superview!.top + 10
      friendsButton.left == friendsButton.superview!.left + 10
      friendsButton.width == 44
      friendsButton.height == 44
    }
    layout(collectionView, topView) { (collectionView, topView) in
      collectionView.top == topView.bottom
      collectionView.bottom == collectionView.superview!.bottom
      collectionView.left == collectionView.superview!.left
      collectionView.right == collectionView.superview!.right
    }
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: animated)
  }

  override func viewWillDisappear(animated: Bool) {
    navigationController?.setNavigationBarHidden(false, animated: animated)
    super.viewWillDisappear(animated)
  }

  // MARK: ManagedViewController

  override func objectsInSection(section: Int) -> RLMArray {
    return Reel.allObjects()
  }

  override func reloadData() {
    API.request(APIRoute.GetReelStream, persistable: Reel.self) { (error) in
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
    reelCell.configureForObject(objectsInSection(indexPath.section).objectAtIndex(UInt(indexPath.row)))
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
    let reel = objectsInSection(indexPath.section).objectAtIndex(UInt(indexPath.row)) as Reel
    reelCell.showPlaybackIndicatorView()
    reelPlayerViewController?.playReel(reel) {
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