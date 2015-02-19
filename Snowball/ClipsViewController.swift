//
//  ClipsViewController.swift
//  Snowball
//
//  Created by James Martinez on 2/9/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import AVFoundation
import Cartography
import UIKit

class ClipsViewController: UIViewController {

  // MARK: - Properties

  let playerViewController = ClipPlayerViewController()

  let collectionView: UICollectionView = {
    let flowLayout = UICollectionViewFlowLayout()
    let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
    collectionView.backgroundColor = UIColor.whiteColor()
    collectionView.registerClass(ClipCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(ClipCollectionViewCell))
    collectionView.registerClass(AddClipCollectionReuseableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: NSStringFromClass(AddClipCollectionReuseableView))
    collectionView.showsHorizontalScrollIndicator = false
    flowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.minimumLineSpacing = 0
    flowLayout.itemSize = ClipCollectionViewCell.size
    return collectionView
  }()

  let cancelPreviewButton: UIButton = {
    let cancelPreviewButton = UIButton()
    cancelPreviewButton.setImage(UIImage(named: "x"), forState: UIControlState.Normal)
    cancelPreviewButton.hidden = true
    return cancelPreviewButton
  }()

  var clips = [Clip]()

  private var previewedClip: Clip?

  private let kClipBookmarkDateKey = "ClipBookmarkDate"

  var clipBookmarkDate: NSDate? {
    get {
      return NSUserDefaults.standardUserDefaults().objectForKey(kClipBookmarkDateKey) as? NSDate
    }
    set {
      NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: kClipBookmarkDateKey)
      NSUserDefaults.standardUserDefaults().synchronize()
    }
  }

  var delegate: ClipsViewControllerDelegate?

  private let currentClipScrollPosition = UICollectionViewScrollPosition.Right

  private var playing: Bool = false {
    didSet {
      scaleVisibleClipThumbnails(playing)
    }
  }

  private var bookmarkedClip: Clip? {
    if let bookmarkDate = clipBookmarkDate {
      for clip in clips {
        if let clipCreatedAt = clip.createdAt {
          let comparisonResult = bookmarkDate.compare(clipCreatedAt)
          if comparisonResult == NSComparisonResult.OrderedAscending || comparisonResult == NSComparisonResult.OrderedSame {
            return clip
          }
        }
      }
    }
    return clips.first
  }

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    playerViewController.delegate = self
    addChildViewController(playerViewController)
    view.addSubview(playerViewController.view)
    playerViewController.didMoveToParentViewController(self)
    layout(playerViewController.view) { (playerView) in
      playerView.left == playerView.superview!.left
      playerView.top == playerView.superview!.top
      playerView.right == playerView.superview!.right
      playerView.height == playerView.superview!.width
    }

    cancelPreviewButton.addTarget(self, action: "cancelPreviewButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    view.addSubview(cancelPreviewButton)
    layout(cancelPreviewButton) { (cancelPreviewButton) in
      let margin: Float = 10
      let width: Float = 44
      cancelPreviewButton.centerX == cancelPreviewButton.superview!.centerX
      cancelPreviewButton.top == cancelPreviewButton.superview!.top + margin
      cancelPreviewButton.width == width
      cancelPreviewButton.height == width
    }

    collectionView.dataSource = self
    collectionView.delegate = self
    view.addSubview(collectionView)
    layout(collectionView, playerViewController.view) { (collectionView, playerView) in
      collectionView.left == collectionView.superview!.left
      collectionView.top == playerView.bottom
      collectionView.right == collectionView.superview!.right
      collectionView.bottom == collectionView.superview!.bottom
    }
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    refresh()
  }

  // MARK: - Internal

  func previewClip(clip: Clip) {
    previewedClip = clip
    showAddClipButton()
    playing = true
    delegate?.willBeginPlayback()
    cancelPreviewButton.hidden = false
    playerViewController.playClip(clip)
  }

  func endPlayback() {
    previewedClip = nil
    playerViewController.endPlayback()
    hideAddClipButton()
    cancelPreviewButton.hidden = true
    playing = false
    delegate?.didEndPlayback()
  }

  // MARK: - Private

  private func refresh() {
    API.request(Router.GetClipStream).responseJSON { (request, response, JSON, error) in
      if let JSON = JSON as? [AnyObject] {
        self.clips = Clip.importJSON(JSON)
        self.collectionView.reloadData()
        self.scrollToBookmarkedClip()
      }
    }
  }

  private func showAddClipButton() {
    UIView.animateWithDuration(1, animations: {
      let flowLayout = self.collectionView.collectionViewLayout as UICollectionViewFlowLayout
      flowLayout.footerReferenceSize = AddClipCollectionReuseableView.size
      }) { (completed) in
        self.scrollToEnd()
    }
  }

  private func hideAddClipButton() {
    let flowLayout = self.collectionView.collectionViewLayout as UICollectionViewFlowLayout
    if flowLayout.footerReferenceSize.width > 0 {
      let lastSection = collectionView.numberOfSections() - 1
      if lastSection >= 0 {
        let lastItem = collectionView.numberOfItemsInSection(lastSection) - 1
        if lastItem >= 0 {
          let indexPath = NSIndexPath(forItem: lastItem, inSection: lastSection)
          collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: currentClipScrollPosition, animated: true)
        }
      }
      let delay = Int64(NSEC_PER_MSEC * 250) // 0.25 seconds
      let time = dispatch_time(DISPATCH_TIME_NOW, delay)
      dispatch_after(time, dispatch_get_main_queue()) {
        let flowLayout = self.collectionView.collectionViewLayout as UICollectionViewFlowLayout
        flowLayout.footerReferenceSize = CGSizeZero
      }
    }
  }

  private func scrollToEnd() {
    let contentSize = collectionView.collectionViewLayout.collectionViewContentSize()
    let width = collectionView.collectionViewLayout.collectionViewContentSize().width
    if width > 0 {
      let endRect = CGRect(x: width - 1, y: 0, width: 1, height: 1)
      collectionView.scrollRectToVisible(endRect, animated: true)
    }
  }

  private func scrollToBookmarkedClip() {
    if let bookmarkedClip = bookmarkedClip {
      scrollToClip(bookmarkedClip)
    }
  }

  private func scrollToClip(clip: Clip) {
    let indexPath = NSIndexPath(forItem: indexOfClip(clip), inSection: 0)
    collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: currentClipScrollPosition, animated: false)
  }

  private func indexOfClip(clip: Clip) -> Int {
    let objcClips = clips as NSArray
    return objcClips.indexOfObject(clip)
  }

  private func clipAfterClip(clip: Clip) -> Clip? {
    let nextClipIndex = indexOfClip(clip) + 1
    if nextClipIndex < clips.count {
      return clips[nextClipIndex]
    }
    return nil
  }

  private func clipsToPlayWithClip(clip: Clip) -> [Clip] {
    let clipIndex = indexOfClip(clip)
    let slice = clips[clipIndex..<clips.count]
    let clipsToPlay = Array(slice)
    return clipsToPlay
  }

  private func updateBookmarkToClip(clip: Clip) {
    if let bookmarkDate = clipBookmarkDate {
      if let clipCreatedAt = clip.createdAt {
        if bookmarkDate.compare(clipCreatedAt) == NSComparisonResult.OrderedAscending {
          clipBookmarkDate = clip.createdAt
        }
      }
    } else {
      clipBookmarkDate = clip.createdAt
    }
  }

  @objc private func cancelPreviewButtonTapped() {
    endPlayback()
  }

  private func scaleVisibleClipThumbnails(down: Bool) {
    for cell in collectionView.visibleCells() {
      let cell = cell as ClipCollectionViewCell
      cell.scaleClipThumbnail(down, animated: true)
    }
  }
}

// MARK: -

extension ClipsViewController: UICollectionViewDataSource {

  // MARK: - UICollectionViewDataSource

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return clips.count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(ClipCollectionViewCell), forIndexPath: indexPath) as ClipCollectionViewCell
    cell.scaleClipThumbnail(playing, animated: false)
    let clip = clips[indexPath.row]
    cell.configureForClip(clip)
    return cell
  }

  func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    let addClipView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: NSStringFromClass(AddClipCollectionReuseableView), forIndexPath: indexPath) as AddClipCollectionReuseableView
    addClipView.scaleAddClipButton(true, animated: false)
    addClipView.delegate = self
    return addClipView
  }
}

// MARK: -

extension ClipsViewController: UICollectionViewDelegate {

  // MARK: - UICollectionViewDelegate

  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let clip = clips[indexPath.row]
    if playing {
      endPlayback()
    } else {
      collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: currentClipScrollPosition, animated: true)
      playing = true
      delegate?.willBeginPlayback()

      playerViewController.endPlayback()
      playerViewController.playClips(clipsToPlayWithClip(clip))
    }
  }
}

// MARK: -

extension ClipsViewController: ClipPlayerViewControllerDelegate {

  // MARK: - ClipPlayerViewControllerDelegate

  func playerItemDidPlayToEndTime(playerItem: ClipPlayerItem) {
    if let previewedClip = previewedClip {
      if playerItem.clip.videoURL == previewedClip.videoURL {
        playerViewController.player.seekToTime(kCMTimeZero)
        playerViewController.player.play()
        return
      }
    }

    if let nextClip = clipAfterClip(playerItem.clip) {
      let indexPath = NSIndexPath(forItem: indexOfClip(nextClip), inSection: 0)
      collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: currentClipScrollPosition, animated: true)
    } else {
      endPlayback()
    }
    updateBookmarkToClip(playerItem.clip)
  }
}

// MARK: -

extension ClipsViewController: AddClipCollectionReuseableViewDelegate {

  // MARK: - AddClipCollectionReuseableViewDelegate

  func addClipButtonTappedInView(view: AddClipCollectionReuseableView) {
    if let clip = previewedClip {
      endPlayback()
      view.scaleAddClipButton(false, animated: true)
      clips.append(clip)
      let indexPath = NSIndexPath(forItem: clips.count - 1, inSection: 0)
      collectionView.insertItemsAtIndexPaths([indexPath])
      collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: currentClipScrollPosition, animated: true)
      API.uploadClip(clip) { (request, response, JSON, error) in
        if let error = error {
          error.print("upload clip")
          displayAPIErrorToUser(JSON)
        }
      }
    }
  }
}

// MARK: - 

protocol ClipsViewControllerDelegate: class {
  func willBeginPlayback()
  func didEndPlayback()
}