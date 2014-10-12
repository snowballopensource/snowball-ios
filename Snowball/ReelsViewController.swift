//
//  ReelViewController.swift
//  Snowball
//
//  Created by James Martinez on 9/24/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class ReelsViewController: ManagedTableViewController {
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
    let cameraViewController = CameraViewController()
    addChildViewController(cameraViewController)
    topView.cameraView = cameraViewController.view as? CameraView
    topView.addFullViewSubview(topView.cameraView!)
    let reelPlayerViewController = ReelPlayerViewController()
    addChildViewController(reelPlayerViewController)
    topView.playerView = reelPlayerViewController.view as? PlayerView
    topView.addFullViewSubview(topView.playerView!)
    view.addSubview(topView)

    friendsButton.setTitle(NSLocalizedString("Friends"), forState: UIControlState.Normal)
    friendsButton.setTitleColorWithAutomaticHighlightColor()
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
      friendsButton.left == friendsButton.superview!.left + 16
      friendsButton.height == 44
    }
    layout(tableView, topView) { (tableView, topView) in
      tableView.top == topView.bottom
      tableView.bottom == tableView.superview!.bottom
      tableView.left == tableView.superview!.left
      tableView.right == tableView.superview!.right
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
    API.request(APIRoute.GetReelStream).responsePersistable(Reel.self) { (error) in
      if error != nil { error?.display(); return }
      self.tableView.reloadData()
    }
  }

  // MARK: ManagedTableViewController

  override func cellTypeInSection(section: Int) -> UITableViewCell.Type {
    return ReelTableViewCell.self
  }

  override func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    super.configureCell(cell, atIndexPath: indexPath)
    if !scrolling {
      let reelCell = cell as ReelTableViewCell
      reelCell.startPlayback()
    }
  }

  // MARK: UITableViewDelegate

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let reelCell = tableView.cellForRowAtIndexPath(indexPath) as ReelTableViewCell
    let reel = objectsInSection(indexPath.section).objectAtIndex(UInt(indexPath.row)) as Reel
    reelCell.showPlaybackIndicatorView()
    reelPlayerViewController?.playReel(reel) {
      reelCell.hidePlaybackIndicatorView()
    }
  }

  // MARK: UIScrollViewDelegate

  func scrollViewWillBeginDragging(scrollView: UIScrollView) {
    scrolling = true
    for cell in tableView.visibleCells() {
      let reelCell = cell as ReelTableViewCell
      reelCell.pausePlayback()
    }
  }

  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    scrolling = false
    for cell in tableView.visibleCells() {
      let reelCell = cell as ReelTableViewCell
      reelCell.startPlayback()
    }
  }
}