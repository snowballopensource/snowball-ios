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

  private func startPlaybackForVisibleReelCells() {
    for cell in tableView.visibleCells() {
      let reelCell = cell as ReelTableViewCell
      reelCell.startPlayback()
    }
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
    layout(tableView, topMediaView!) { (tableView, topMediaView) in
      tableView.top == topMediaView.bottom
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
    topMediaViewController?.playReel(reel) {
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

  func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    if velocity.y == 0 {
      scrolling = false
      startPlaybackForVisibleReelCells()
    }
  }

  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    scrolling = false
    startPlaybackForVisibleReelCells()
  }
}