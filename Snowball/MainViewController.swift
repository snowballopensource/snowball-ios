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
  private var playbackIndexOffset = 0
  private var clipsSectionIndex: Int { get { return 0 } } // Readonly
  private var scrollingBeforePlayback = false

  func switchToFriendsNavigationController() {
    switchToNavigationController(FriendsNavigationController())
  }

  private func beginPlaybackAtClipsIndex(index: Int) {
    // Start playing clips
    playbackIndexOffset = 0
    let clips = objectsInSection(clipsSectionIndex)
    let clip = clips.objectAtIndex(UInt(index)) as Clip
    topMediaViewController?.playClips(since: clip.createdAt,
      clipCompletionHandler: { () -> () in
        // Mark last clip as most recently watched
        let lastClipIndex = index + self.playbackIndexOffset
        let lastWatchedClip = clips.objectAtIndex(UInt(lastClipIndex)) as Clip
        Clip.lastWatchedClip = lastWatchedClip

        // Scroll next clip to center
        self.playbackIndexOffset++
        let nextClipIndex = index + self.playbackIndexOffset
        if nextClipIndex < Int(clips.count) {
          let nextClipCellIndexPath = NSIndexPath(forItem: nextClipIndex, inSection: self.clipsSectionIndex)
          Async.main {
            self.collectionView.scrollToItemAtIndexPath(nextClipCellIndexPath, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
          }
        }
      }, playerCompletionHandler: { () -> () in
        // TODO: do something here
        // All clips are done playing, whether by user or by no more clips. :)
    })
  }

  // MARK: -

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    let flowLayout = collectionView.collectionViewLayout as UICollectionViewFlowLayout
    flowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal

    let topMediaViewController = TopMediaViewController()
    addChildViewController(topMediaViewController)
    view.addSubview(topMediaViewController.view)
    layout(topMediaView!) { (topMediaView) in
      topMediaView.top == topMediaView.superview!.top
      topMediaView.bottom == topMediaView.top + Float(UIScreen.mainScreen().bounds.width)
      topMediaView.left == topMediaView.superview!.left
      topMediaView.right == topMediaView.superview!.right
    }

    friendsButton.setTitle(NSLocalizedString("Friends"), forState: UIControlState.Normal)
    friendsButton.setTitleColorWithAutomaticHighlightColor()
    friendsButton.addTarget(self, action: "switchToFriendsNavigationController", forControlEvents: UIControlEvents.TouchUpInside)
    view.addSubview(friendsButton)
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

    if let clip = Clip.lastWatchedClip {
      let clipIndex = objectsInSection(clipsSectionIndex).indexOfObject(clip)
      let clipIndexPath = NSIndexPath(forItem: Int(clipIndex), inSection: clipsSectionIndex)
      collectionView.scrollToItemAtIndexPath(clipIndexPath, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: false)
    }
  }

  override func viewWillDisappear(animated: Bool) {
    navigationController?.setNavigationBarHidden(false, animated: animated)
    super.viewWillDisappear(animated)
  }

  // MARK: ManagedViewController

  override func objectsInSection(section: Int) -> RLMResults {
    return Clip.playableClips
  }

  override func reloadData() {
    API.request(APIRoute.GetClipStream).responsePersistable(Clip.self) { (object, error) in
      if error != nil { error?.display(); return }
      self.collectionView.reloadData()
    }
  }

  // MARK: ManagedCollectionViewController

  override func cellTypeInSection(section: Int) -> UICollectionViewCell.Type {
    return ClipCollectionViewCell.self
  }

  // MARK: UICollectionViewDelegate

  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    // Scroll to selected clip cell
    // When done scrolling, the scroll view delegate method will start playing the clip.
    scrollingBeforePlayback = true
    collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
  }

  // MARK: UICollectionViewDelegateFlowLayout

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
    if section == clipsSectionIndex {
      return UIEdgeInsetsMake(0, ClipCollectionViewCell.size().width, 0, ClipCollectionViewCell.size().width)
    }
    return UIEdgeInsetsZero
  }

  // MARK: UIScrollViewDelegate

  func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
    if scrollingBeforePlayback == true {
      scrollingBeforePlayback = false
      let clipCellIndexPath = self.collectionView.indexPathsForSelectedItems()?.first as NSIndexPath
      beginPlaybackAtClipsIndex(clipCellIndexPath.item)
    }
  }
}