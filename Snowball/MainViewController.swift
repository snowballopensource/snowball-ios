//
//  MainViewController.swift
//  Snowball
//
//  Created by James Martinez on 9/24/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class MainViewController: ManagedCollectionViewController, TopMediaViewControllerDelegate {
  private let friendsButton = UIButton()
  private let flipCameraButton = UIButton()
  private let previewCancelButton = UIButton()
  private let addClipButton = UIButton()
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

  func switchToFriendsNavigationController() {
    switchToNavigationController(FriendsNavigationController())
  }

  func flipCamera() {
    topMediaViewController?.flipCamera()
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

  func cancelPreview() {
    topMediaViewController?.endRecordingPreview()
    hidePreviewCancelButton()
    hideAddClipButton()
    showTopMenu()
  }

  func addClip() {
    if let fileURL = topMediaViewController?.recordedClipFileURL {
      Async.userInitiated {
        API.uploadClip(fileURL)
      }
    }
    cancelPreview()
  }

  private func showPreviewCancelButton() {
    UIView.animateWithDuration(0.2) {
      var origin = self.previewCancelButton.frame.origin
      origin = CGPointMake(origin.x, 10)
      self.previewCancelButton.frame.origin = origin
    }
  }

  private func hidePreviewCancelButton() {
    UIView.animateWithDuration(0.2) {
      var size = self.previewCancelButton.frame.size
      var origin = self.previewCancelButton.frame.origin
      origin = CGPointMake(origin.x, -size.height)
      self.previewCancelButton.frame.origin = origin
    }
  }

  private func showTopMenu() {
    UIView.animateWithDuration(0.2) {
      var friendsButtonOrigin = self.friendsButton.frame.origin
      friendsButtonOrigin = CGPointMake(friendsButtonOrigin.x, 10)
      self.friendsButton.frame.origin = friendsButtonOrigin

      var flipCameraButtonOrigin = self.flipCameraButton.frame.origin
      flipCameraButtonOrigin = CGPointMake(flipCameraButtonOrigin.x, 10)
      self.flipCameraButton.frame.origin = flipCameraButtonOrigin
    }
  }

  private func hideTopMenu() {
    UIView.animateWithDuration(0.2) {
      var friendsButtonSize = self.friendsButton.frame.size
      var friendsButtonOrigin = self.friendsButton.frame.origin
      friendsButtonOrigin = CGPointMake(friendsButtonOrigin.x, -friendsButtonSize.height)
      self.friendsButton.frame.origin = friendsButtonOrigin

      var flipCameraButtonSize = self.flipCameraButton.frame.size
      var flipCameraButtonOrigin = self.flipCameraButton.frame.origin
      flipCameraButtonOrigin = CGPointMake(flipCameraButtonOrigin.x, -flipCameraButtonSize.height)
      self.flipCameraButton.frame.origin = flipCameraButtonOrigin
    }
  }

  private func showAddClipButton() {
    UIView.animateWithDuration(0.2) {
      var origin = self.addClipButton.frame.origin
      origin = CGPointMake(origin.x, 10)
      self.addClipButton.frame.origin = origin
    }
  }

  private func hideAddClipButton() {
    UIView.animateWithDuration(0.2) {
      var size = self.addClipButton.frame.size
      var origin = self.addClipButton.frame.origin
      origin = CGPointMake(origin.x, -size.height)
      self.addClipButton.frame.origin = origin
    }
  }

  // MARK: -

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    let flowLayout = collectionView.collectionViewLayout as UICollectionViewFlowLayout
    flowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal

    let topMediaViewController = TopMediaViewController()
    topMediaViewController.delegate = self
    addChildViewController(topMediaViewController)
    view.addSubview(topMediaViewController.view)
    layout(topMediaView!) { (topMediaView) in
      topMediaView.top == topMediaView.superview!.top
      topMediaView.bottom == topMediaView.top + Float(UIScreen.mainScreen().bounds.width)
      topMediaView.left == topMediaView.superview!.left
      topMediaView.right == topMediaView.superview!.right
    }

    friendsButton.setImage(UIImage(named: "friends-normal"), forState: UIControlState.Normal)
    friendsButton.imageView?.contentMode = UIViewContentMode.Center
    friendsButton.addTarget(self, action: "switchToFriendsNavigationController", forControlEvents: UIControlEvents.TouchUpInside)
    view.addSubview(friendsButton)
    layout(friendsButton) { (friendsButton) in
      friendsButton.top == friendsButton.superview!.top + 10
      friendsButton.left == friendsButton.superview!.left + 15
      friendsButton.height == 44
      friendsButton.width == 44
    }

    flipCameraButton.setImage(UIImage(named: "cameraflip-normal"), forState: UIControlState.Normal)
    flipCameraButton.imageView?.contentMode = UIViewContentMode.Center
    flipCameraButton.addTarget(self, action: "flipCamera", forControlEvents: UIControlEvents.TouchUpInside)
    view.addSubview(flipCameraButton)
    layout(flipCameraButton) { (flipCameraButton) in
      flipCameraButton.top == flipCameraButton.superview!.top + 10
      flipCameraButton.right == flipCameraButton.superview!.right - 15
      flipCameraButton.height == 44
      flipCameraButton.width == 44
    }

    addClipButton.setTitle(NSLocalizedString("Add Clip"), forState: UIControlState.Normal)
    addClipButton.setTitleColorWithAutomaticHighlightColor()
    addClipButton.addTarget(self, action: "addClip", forControlEvents: UIControlEvents.TouchUpInside)
    view.addSubview(addClipButton)
    layout(addClipButton) { (addClipButton) in
      addClipButton.bottom == addClipButton.superview!.top
      addClipButton.right == addClipButton.superview!.right - 16
      addClipButton.height == 44
    }

    previewCancelButton.setTitle(NSLocalizedString("Cancel"), forState: UIControlState.Normal)
    previewCancelButton.setTitleColorWithAutomaticHighlightColor()
    previewCancelButton.addTarget(self, action: "cancelPreview", forControlEvents: UIControlEvents.TouchUpInside)
    view.addSubview(previewCancelButton)
    layout(previewCancelButton) { (previewCancelButton) in
      previewCancelButton.bottom == previewCancelButton.superview!.top
      previewCancelButton.centerX == previewCancelButton.superview!.centerX
      previewCancelButton.height == 44
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
    collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
    beginPlaybackAtClipsIndex(indexPath.item)
  }

  // MARK: UICollectionViewDelegateFlowLayout

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
    if section == clipsSectionIndex {
      return UIEdgeInsetsMake(0, ClipCollectionViewCell.size().width, 0, ClipCollectionViewCell.size().width)
    }
    return UIEdgeInsetsZero
  }

  // MARK: TopMediaViewControllerDelegate

  func capturedClipPreviewWillStart() {
    hideTopMenu()
    showPreviewCancelButton()
    showAddClipButton()
  }

  func capturedClipPreviewDidEnd() {
    hidePreviewCancelButton()
    showTopMenu()
  }
}