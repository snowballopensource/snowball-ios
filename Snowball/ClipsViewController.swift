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
    collectionView.insertItemsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)])
    scrollToClip(clip, animated: true)
  }

  func reloadCellForClip(clip: Clip) {
    let index = indexOfClip(clip)
    collectionView.reloadItemsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)])
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

  private func clipAfterClip(clip: Clip) -> Clip? {
    let nextClipIndex = indexOfClip(clip) + 1
    if nextClipIndex < clips.count {
      return clips[nextClipIndex]
    }
    return nil
  }

  private func scrollToClip(clip: Clip, animated: Bool = true) {
    let indexPath = NSIndexPath(forItem: indexOfClip(clip), inSection: 0)
    collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Right, animated: animated)
  }

  private func removeClipFromTimeline(clip: Clip) {
    let index = indexOfClip(clip)
    clips.removeAtIndex(index)
    collectionView.deleteItemsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)])
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
    let clip = clips[indexPath.row]
    cell.configureForClip(clip)
    cell.setInPlayState(player.playing, animated: false)
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
      let clip = clips[indexPath.row]
      if clip.state == ClipState.Pending {
        delegate?.userDidAcceptPreviewClip(clip)
      } else {
        player.playClip(clip)
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
      cell.setInPlayState(true, animated: true)
    }
    delegate?.playerWillBeginPlayback()
  }

  func playerDidEndPlayback() {
    for cell in collectionView.visibleCells() {
      let cell = cell as ClipCollectionViewCell
      cell.setInPlayState(false, animated: true)
    }
    delegate?.playerDidEndPlayback()
  }

  func playerWillPlayClip(clip: Clip) {
    scrollToClip(clip)
  }

  func clipDidPlayToEndTime(clip: Clip) {
    bookmarkedClip = clip
    if let nextClip = clipAfterClip(clip) {
      player.playClip(nextClip)
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