//
//  MainViewController.swift
//  Snowball
//
//  Created by James Martinez on 9/24/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class MainViewController: ManagedCollectionViewController {
  private let friendsButton = UIButton()
  private var scrolling = false
  private var topMediaView: UIView? {
    return topMediaViewController?.view
  }
  private var topMediaViewController: TopMediaViewController? {
    get {
      for childViewController in childViewControllers {
        if childViewController is TopMediaViewController {
          return childViewController as? TopMediaViewController
        }
      }
      return nil
    }
  }

  private func switchToFriendsNavigationController() {
    switchToNavigationController(FriendsNavigationController())
  }

  // MARK: -

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()
    let topMediaViewController = TopMediaViewController()
    addChildViewController(topMediaViewController)
    view.addSubview(topMediaViewController.view)

    friendsButton.setTitle(NSLocalizedString("Friends"), forState: UIControlState.Normal)
    friendsButton.setTitleColorWithAutomaticHighlightColor()
    friendsButton.addTarget(self, action: "switchToFriendsNavigationController", forControlEvents: UIControlEvents.TouchUpInside)
    view.addSubview(friendsButton)
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    layout(topMediaView!) { (topMediaView) in
      topMediaView.top == topMediaView.superview!.top
      topMediaView.bottom == topMediaView.top + Float(UIScreen.mainScreen().bounds.width)
      topMediaView.left == topMediaView.superview!.left
      topMediaView.right == topMediaView.superview!.right
    }
    layout(friendsButton) { (friendsButton) in
      friendsButton.top == friendsButton.superview!.top + 10
      friendsButton.left == friendsButton.superview!.left + 16
      friendsButton.height == 44
    }
    layout(collectionView, topMediaView!) { (collectionView, topMediaView) in
      collectionView.top == topMediaView.bottom
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

  override func objectsInSection(section: Int) -> RLMResults {
    return Clip.allObjects()
  }

  override func reloadData() {
    API.request(APIRoute.GetClipFeed).responsePersistable(Clip.self) { (object, error) in
      if error != nil { error?.display(); return }
      self.collectionView.reloadData()
    }
  }

  // MARK: ManagedTableViewController

  override func cellTypeInSection(section: Int) -> UICollectionViewCell.Type {
    return ClipCollectionViewCell.self
  }

  override func configureCell(cell: UICollectionViewCell, atIndexPath indexPath: NSIndexPath) {
    super.configureCell(cell, atIndexPath: indexPath)
    if !scrolling {
      let clipCell = cell as ClipCollectionViewCell
      // TODO: do this again
      // clipCell.startPlayback()
    }
  }

  // MARK: UICollectionViewDelegate

  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let clipCell = collectionView.cellForItemAtIndexPath(indexPath) as ClipCollectionViewCell
    let clip = objectsInSection(indexPath.section).objectAtIndex(UInt(indexPath.row)) as Clip
    // TODO: add back
//    clipCell.showPlaybackIndicatorView()
//    topMediaViewController?.playReel(reel) {
//      reelCell.hidePlaybackIndicatorView()
//    }
  }
}