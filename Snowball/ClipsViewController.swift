//
//  ClipsViewController.swift
//  Snowball
//
//  Created by James Martinez on 3/2/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import AVFoundation
import Cartography
import UIKit

class ClipsViewController: UIViewController {

  // MARK: - Properties

  var delegate: ClipsViewControllerDelegate?

  private let playerView: PlayerView = {
    let view = PlayerView()
    view.backgroundColor = UIColor.blackColor()
    return view
    }()

  private let player = ClipPlayer()

  private let collectionView: UICollectionView = {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.minimumLineSpacing = 0
    flowLayout.itemSize = ClipCollectionViewCell.size

    let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
    collectionView.backgroundColor = UIColor.whiteColor()
    collectionView.registerClass(ClipCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(ClipCollectionViewCell))
    collectionView.showsHorizontalScrollIndicator = false
    return collectionView
    }()

  private let activityIndicatorView: UIActivityIndicatorView = {
    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    activityIndicatorView.color = UIColor.darkGrayColor()
    return activityIndicatorView
    }()

  private var clips: [Clip] = []

  private let kClipBookmarkDateKey = "ClipBookmarkDate"
  private var bookmarkedClip: Clip? {
    get {
      let clipBookmarkDate = NSUserDefaults.standardUserDefaults().objectForKey(kClipBookmarkDateKey) as? NSDate
      if let bookmarkDate = clipBookmarkDate {
        for clip in clips {
          if let clipCreatedAt = clip.createdAt {
            if bookmarkDate.compare(clipCreatedAt) == NSComparisonResult.OrderedAscending {
              return clip
            }
          }
        }
      }
      return clips.first
    }
    set {
      if let newClipBookmarkDate = newValue?.createdAt {
        if let oldClipBookmarkDate = self.bookmarkedClip?.createdAt {
          if oldClipBookmarkDate.compare(newClipBookmarkDate) == NSComparisonResult.OrderedAscending {
            NSUserDefaults.standardUserDefaults().setObject(newClipBookmarkDate, forKey: kClipBookmarkDateKey)
            NSUserDefaults.standardUserDefaults().synchronize()
          }
        }
      }
    }
  }

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    player.delegate = self

    playerView.player = player
    view.addSubview(playerView)
    layout(playerView) { (playerView) in
      playerView.left == playerView.superview!.left
      playerView.top == playerView.superview!.top
      playerView.right == playerView.superview!.right
      playerView.height == playerView.width
    }

    let collectionViewWidthPreloadMultiple: CGFloat = 3
    let rightInset = view.bounds.width * collectionViewWidthPreloadMultiple - view.bounds.width
    collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: rightInset)
    collectionView.dataSource = self
    collectionView.delegate = self
    view.addSubview(collectionView)
    layout(collectionView, playerView) { (collectionView, playerView) in
      collectionView.left == collectionView.superview!.left
      collectionView.top == playerView.bottom
      collectionView.width == collectionView.superview!.width * collectionViewWidthPreloadMultiple
      collectionView.bottom == collectionView.superview!.bottom
    }

    collectionView.addSubview(activityIndicatorView)
    layout(activityIndicatorView) { (activityIndicatorView) in
      activityIndicatorView.centerX == activityIndicatorView.superview!.centerX / collectionViewWidthPreloadMultiple
      activityIndicatorView.top == activityIndicatorView.superview!.top + 50
    }
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    NSNotificationCenter.defaultCenter().addObserver(self, selector: "refresh", name: UIApplicationWillEnterForegroundNotification, object: nil)

    refresh()
  }

  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)

    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  // MARK: - Internal

  func addClipToTimeline(clip: Clip) {
    clips.append(clip)
    let index = indexOfClip(clip)
    collectionView.insertItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
    scrollToClip(clip, animated: true)
  }

  func reloadCellForClip(clip: Clip) {
    let index = indexOfClip(clip)
    UIView.animateWithDuration(0.4) {
      self.collectionView.reloadItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
    }
  }

  func removePendingClipFromTimeline() {
    if let lastClip = clips.last {
      if lastClip.state == ClipState.Pending {
        removeClipFromTimeline(lastClip)
      }
    }
  }

  // MARK: - Private

  @objc private func refresh() {
    activityIndicatorView.startAnimating()
    API.request(Router.GetClipStream).responseJSON { (request, response, JSON, error) in
      if let JSON = JSON as? [AnyObject] {
        self.clips = Clip.importJSON(JSON)
        self.collectionView.reloadData()
        if let bookmarkedClip = self.bookmarkedClip {
          self.scrollToClip(bookmarkedClip, animated: false)
        }
      }
      self.activityIndicatorView.stopAnimating()
    }
  }

  private func indexOfClip(clip: Clip) -> Int {
    let clips = self.clips as NSArray
    return clips.indexOfObject(clip)
  }

  private func allClipsAfterClip(clip: Clip) -> [Clip] {
    let nextClipIndex = indexOfClip(clip) + 1
    if nextClipIndex < clips.count {
      let clipsSlice = clips[nextClipIndex..<clips.count]
      return Array(clipsSlice)
    }
    return []
  }

  private func clipAfterClip(clip: Clip) -> Clip? {
    return allClipsAfterClip(clip).first
  }

  private func clipForCell(cell: ClipCollectionViewCell) -> Clip? {
    let indexPath = collectionView.indexPathForCell(cell)
    if let indexPath = indexPath {
      if indexPath.item < clips.count {
        return clips[indexPath.item]
      }
    }
    return nil
  }

  private func cellForClip(clip: Clip) -> ClipCollectionViewCell? {
    let indexPath = NSIndexPath(forItem: indexOfClip(clip), inSection: 0)
    return collectionView.cellForItemAtIndexPath(indexPath) as? ClipCollectionViewCell
  }

  private func clipIsPlayingClip(clip: Clip) -> Bool {
    if let playingClip = player.clip {
      if clip.id == playingClip.id {
        return true
      }
    }
    return false
  }

  private func scrollToClip(clip: Clip, animated: Bool = true) {
    let indexPath = NSIndexPath(forItem: indexOfClip(clip), inSection: 0)
    collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Right, animated: animated)
  }

  private func removeClipFromTimeline(clip: Clip) {
    let index = indexOfClip(clip)
    clips.removeAtIndex(index)
    collectionView.deleteItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
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
    let clip = clips[indexPath.item]
    cell.configureForClip(clip)
    cell.setInPlayState(player.playing, isCurrentPlayingClip: false, animated: false)
    return cell
  }
}

// MARK: -

extension ClipsViewController: UICollectionViewDelegate {

  // MARK: - UICollectionViewDelegate

  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if player.playing {
      player.stop()
    } else {
      let clip = clips[indexPath.item]
      if clip.state == ClipState.Pending {
        delegate?.userDidAcceptPreviewClip(clip)
      } else {
        player.playClips([clip] + allClipsAfterClip(clip))
      }
    }
  }
}

// MARK: -

extension ClipsViewController: ClipPlayerDelegate {

  // MARK: - ClipPlayerDelegate

  func playerWillBeginPlayback() {
    for cell in collectionView.visibleCells() {
      let cell = cell as ClipCollectionViewCell
      if let cellClip = clipForCell(cell) {
        if let playerClip = player.clip {
          if playerClip.id == cellClip.id {
            cell.setInPlayState(true, isCurrentPlayingClip: true, animated: true)
          } else {
            cell.setInPlayState(true, isCurrentPlayingClip: false, animated: true)
          }
        }
      }
    }
    delegate?.playerWillBeginPlayback()
  }

  func playerDidEndPlayback() {
    for cell in collectionView.visibleCells() {
      let cell = cell as ClipCollectionViewCell
      cell.setInPlayState(false, isCurrentPlayingClip: false, animated: true)
    }
    delegate?.playerDidEndPlayback()
  }

  func playerWillPlayClip(clip: Clip) {
    scrollToClip(clip)
    Analytics.track("Watch Clip")
  }

  func clipDidPlayToEndTime(clip: Clip) {
    bookmarkedClip = clip
    if let cell = cellForClip(clip) {
      cell.setInPlayState(true, isCurrentPlayingClip: false, animated: true)
    }
    if let nextClip = clipAfterClip(clip) {
      if let nextCell = cellForClip(nextClip) {
        nextCell.setInPlayState(true, isCurrentPlayingClip: true, animated: true)
      }
    } else {
      player.stop()
    }
  }
}

// MARK: -

protocol ClipsViewControllerDelegate {
  func playerWillBeginPlayback()
  func playerDidEndPlayback()
  func userDidAcceptPreviewClip(clip: Clip)
}