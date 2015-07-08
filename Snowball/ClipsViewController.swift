//
//  ClipsViewController.swift
//  Snowball
//
//  Created by James Martinez on 3/2/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import AVFoundation
import Cartography
import Haneke
import UIKit

class ClipsViewController: UIViewController {

  // MARK: - Properties

  var delegate: ClipsViewControllerDelegate?

  private let player = ClipPlayer()

  private let playerView = PlayerView()

  private var playerLayer: AVPlayerLayer {
    return playerView.layer as! AVPlayerLayer
  }

  private let playerThumbnailImageView = UIImageView()

  let collectionView: UICollectionView = {
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

  let activityIndicatorView: UIActivityIndicatorView = {
    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    activityIndicatorView.color = UIColor.darkGrayColor()
    return activityIndicatorView
    }()

  let pauseImageView: UIImageView = {
    let imageView = UIImageView(image: UIImage(named: "pause"))
    imageView.contentMode = UIViewContentMode.Center
    return imageView
  }()

  let playerControlSingleTapGestureRecognizer: UITapGestureRecognizer = {
    let gestureRecognizer = UITapGestureRecognizer()
    return gestureRecognizer
  }()

  let playerControlSwipeLeftGestureRecognizer: UISwipeGestureRecognizer = {
    let gestureRecognizer = UISwipeGestureRecognizer()
    gestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
    return gestureRecognizer
  }()

  let playerControlSwipeRightGestureRecognizer: UISwipeGestureRecognizer = {
    let gestureRecognizer = UISwipeGestureRecognizer()
    gestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
    return gestureRecognizer
    }()

  var clips: [Clip] = []

  private let kClipBookmarkDateKey = "ClipBookmarkDate"
  var shouldIgnoreBookmark = false // For profile bookmark
  private var bookmarkedClip: Clip? {
    get {
      if !shouldIgnoreBookmark {
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
      } else {
        return nil
      }
    }
    set {
      if !shouldIgnoreBookmark {
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
  }

  // MARK: - Initializers

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    player.delegate = self

    view.addSubview(playerThumbnailImageView)
    layout(playerThumbnailImageView) { (playerThumbnailImageView) in
      playerThumbnailImageView.left == playerThumbnailImageView.superview!.left
      playerThumbnailImageView.top == playerThumbnailImageView.superview!.top
      playerThumbnailImageView.right == playerThumbnailImageView.superview!.right
      playerThumbnailImageView.height == playerThumbnailImageView.width
    }

    playerView.player = player
    view.addSubview(playerView)
    layout(playerView) { (playerView) in
      playerView.left == playerView.superview!.left
      playerView.top == playerView.superview!.top
      playerView.right == playerView.superview!.right
      playerView.height == playerView.width
    }

    let collectionViewLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: ClipCollectionViewCell.size.width, bottom: 0, right: ClipCollectionViewCell.size.width)
    collectionView.dataSource = self
    collectionView.delegate = self
    view.addSubview(collectionView)
    layout(collectionView, playerView) { (collectionView, playerView) in
      collectionView.left == collectionView.superview!.left
      collectionView.top == playerView.bottom
      collectionView.width == collectionView.superview!.width
      collectionView.bottom == collectionView.superview!.bottom
    }

    setPauseImageViewHidden(true, animated: false)
    view.addSubview(pauseImageView)
    layout(pauseImageView, collectionView) { (pauseImageView, collectionView) in
      pauseImageView.left == pauseImageView.superview!.left
      pauseImageView.top == collectionView.top
      pauseImageView.right == pauseImageView.superview!.right
      pauseImageView.height == ClipCollectionViewCell.size.width
    }

    view.addSubview(activityIndicatorView)
    layout(activityIndicatorView, collectionView) { (activityIndicatorView, collectionView) in
      activityIndicatorView.centerX == collectionView.centerX
      activityIndicatorView.top == collectionView.top + 50
    }

    playerControlSingleTapGestureRecognizer.addTarget(self, action: "userDidTapPlayerControlGestureRecognizer:")
    playerView.addGestureRecognizer(playerControlSingleTapGestureRecognizer)

    playerControlSwipeLeftGestureRecognizer.addTarget(self, action: "userDidSwipePlayerControlGestureRecognizerLeft:")
    view.addGestureRecognizer(playerControlSwipeLeftGestureRecognizer)
    playerControlSwipeRightGestureRecognizer.addTarget(self, action: "userDidSwipePlayerControlGestureRecognizerRight:")
    view.addGestureRecognizer(playerControlSwipeRightGestureRecognizer)

    NSNotificationCenter.defaultCenter().addObserver(self, selector: "refresh", name: UIApplicationWillEnterForegroundNotification, object: nil)

    NSNotificationCenter.defaultCenter().addObserver(self, selector: "appResigningActive", name: UIApplicationWillResignActiveNotification, object: nil)

    refresh()
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    if let bookmarkedClip = bookmarkedClip {
      scrollToClip(bookmarkedClip, animated: false)
    }
  }

  override func viewWillDisappear(animated: Bool) {
    player.stop()
    super.viewWillDisappear(animated)
  }

  // MARK: - KVO

  override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
    if keyPath == "readyForDisplay" {
      if playerLayer.readyForDisplay {
        playerLayer.removeObserver(self, forKeyPath: "readyForDisplay")
        playerView.hidden = false
      }
    }
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

  func refresh() {
    activityIndicatorView.startAnimating()
    API.request(Router.GetClipStream).responseJSON { (request, response, JSON, error) in
      if let JSON = JSON as? [AnyObject] {
        self.clips = Clip.importJSON(JSON)
        self.collectionView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0, self.collectionView.numberOfSections())))
        if let bookmarkedClip = self.bookmarkedClip {
          self.scrollToClip(bookmarkedClip, animated: false)
        }
      }
      self.activityIndicatorView.stopAnimating()
    }
  }

  func scrollToClip(clip: Clip, animated: Bool = true) {
    let indexPath = NSIndexPath(forItem: indexOfClip(clip), inSection: 0)
    collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: animated)
  }

  // MARK: - Private

  @objc private func userDidTapPlayerControlGestureRecognizer(recognizer: UISwipeGestureRecognizer) {
    if player.playing {
      player.stop()
    }
  }

  @objc private func userDidSwipePlayerControlGestureRecognizerLeft(recognizer: UISwipeGestureRecognizer) {
    if player.playing {
      if let clip = player.currentClip {
        let nextClips = allClipsAfterClip(clip)
        player.restartPlaybackWithNewClips(nextClips)
      }
    }
  }

  @objc private func userDidSwipePlayerControlGestureRecognizerRight(recognizer: UISwipeGestureRecognizer) {
    if player.playing {
      if let clip = player.currentClip {
        if let previousClip = clipBeforeClip(clip) {
          player.restartPlaybackWithNewClips([previousClip] + allClipsAfterClip(previousClip))
        }
      }
    }
  }

  @objc private func appResigningActive() {
    player.stop()
  }

  private func indexOfClip(clip: Clip) -> Int {
    let clips = self.clips as NSArray
    let index = clips.indexOfObject(clip)
    if index == NSNotFound {
      return 0
    }
    return index
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

  private func clipBeforeClip(clip: Clip) -> Clip? {
    let previousClipIndex = indexOfClip(clip) - 1
    if previousClipIndex >= 0  && previousClipIndex < clips.count {
      return clips[previousClipIndex]
    }
    return nil
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
    if let playingClip = player.currentClip {
      if clip.id == playingClip.id {
        return true
      }
    }
    return false
  }

  private func removeClipFromTimeline(clip: Clip) {
    let index = indexOfClip(clip)
    clips.removeAtIndex(index)
    collectionView.deleteItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
  }

  private func setPauseImageViewHidden(hidden: Bool, animated: Bool = true) {
    if animated {
      UIView.animateWithDuration(0.2) {
        self.setPauseImageViewHidden(hidden, animated: false)
      }
    } else {
      let alpha = CGFloat(!hidden)
      pauseImageView.alpha = alpha
    }
  }

  private func setBookmarkPlayheadHiddenForBookmarkedClip(hidden: Bool) {
    if let bookmarkedClip = bookmarkedClip {
      if let cell = cellForClip(bookmarkedClip) {
        cell.setBookmarkPlayheadHidden(hidden)
      }
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
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(ClipCollectionViewCell), forIndexPath: indexPath) as! ClipCollectionViewCell
    let clip = clips[indexPath.item]
    var showBookmark = false
    if let bookmarkedClip = self.bookmarkedClip {
      if clip.id == bookmarkedClip.id {
        showBookmark = true
      }
    }
    cell.configureForClip(clip, showBookmarkPlayhead: showBookmark)
    cell.delegate = self
    let isCurrentPlayingClip = clipIsPlayingClip(clip)
    cell.setInPlayState(player.playing, isCurrentPlayingClip: isCurrentPlayingClip, animated: false)
    return cell
  }
}

// MARK: -

extension ClipsViewController: UICollectionViewDelegate {

  // MARK: - UICollectionViewDelegate

  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let clip = clips[indexPath.item]
    if player.playing {
      let isCurrentPlayingClip = clipIsPlayingClip(clip)
      if isCurrentPlayingClip {
        player.stop()
      } else {
        player.restartPlaybackWithNewClips([clip] + allClipsAfterClip(clip))
      }
    } else {
      if clip.state == ClipState.Pending {
        delegate?.userDidAcceptPreviewClip(clip)
      } else if delegate != nil && delegate!.playerShouldBeginPlayback() {
        playerView.hidden = true
        playerLayer.addObserver(self, forKeyPath: "readyForDisplay", options: nil, context: nil)
        player.playClips([clip] + allClipsAfterClip(clip))
      }
    }
  }
}

// MARK: -

extension ClipsViewController: ClipCollectionViewCellDelegate {

  // MARK: - ClipCollectionViewCellDelegate

  func userDidFlagClipForCell(cell: ClipCollectionViewCell) {
    if let clip = clipForCell(cell) {
      if let id = clip.id {
        let alertController = UIAlertController(title: NSLocalizedString("Flag this clip?", comment: ""), message: NSLocalizedString("Are you sure you want to report this clip as inappropriate?", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Don't Flag", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Flag", comment: ""), style: UIAlertActionStyle.Destructive) { (action) -> Void in
          API.request(Router.FlagClip(clipID: id)).response { (request, response, JSON, error) in
            if error != nil { displayAPIErrorToUser(JSON); return }
            let index = self.indexOfClip(clip)
            self.clips.removeAtIndex(index)
            self.collectionView.deleteItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
          }
          return
          })
        presentViewController(alertController, animated: true, completion: nil)
      }
    }
  }

  func userDidDeleteClipForCell(cell: ClipCollectionViewCell) {
    if let clip = clipForCell(cell) {
      let alertController = UIAlertController(title: NSLocalizedString("Delete this clip?", comment: ""), message: NSLocalizedString("Are you sure you want to delete this clip?", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
      alertController.addAction(UIAlertAction(title: NSLocalizedString("Don't Delete", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil))
      alertController.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: UIAlertActionStyle.Destructive) { (action) in
        let index = self.indexOfClip(clip)
        self.clips.removeAtIndex(index)
        self.collectionView.deleteItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
        if let id = clip.id {
          API.request(Router.DeleteClip(clipID: id)).response { (request, response, JSON, error) in
            if error != nil { displayAPIErrorToUser(JSON); return }
            // TODO: Remove clip from timeline in here
            // This should be done AFTER the new upload style is completed, so we have an ID to delete immediately.
            // let index = self.indexOfClip(clip)
            // self.clips.removeAtIndex(index)
            // self.collectionView.deleteItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
          }
        }
        })
      presentViewController(alertController, animated: true, completion: nil)
    }
  }

  func userDidTapUserButtonForCell(cell: ClipCollectionViewCell) {
    if let clip = clipForCell(cell) {
      if let user = clip.user {
        navigationController?.pushViewController(ProfileViewController(user: user), animated: true)
      }
    }
  }

  func userDidTapLikeButtonForCell(cell: ClipCollectionViewCell) {
    if let clip = clipForCell(cell) {
      if let user = clip.user {
        clip.liked = !clip.liked
        cell.setClipLikedAnimated(liked: clip.liked)
        if let clipID = clip.id {
          var route: Router!
          if clip.liked {
            Analytics.track("Like Clip")
            route = Router.LikeClip(clipID: clipID)
          } else {
            route = Router.UnlikeClip(clipID: clipID)
          }
          API.request(route)
        }
      }
    }
  }
}

// MARK: -

extension ClipsViewController: ClipPlayerDelegate {

  // MARK: - ClipPlayerDelegate

  func playerWillBeginPlayback() {
    for cell in collectionView.visibleCells() {
      let cell = cell as! ClipCollectionViewCell
      if let cellClip = clipForCell(cell) {
        if let playerClip = player.currentClip {
          if playerClip.id == cellClip.id {
            cell.setInPlayState(true, isCurrentPlayingClip: true, animated: true)
          } else {
            cell.setInPlayState(true, isCurrentPlayingClip: false, animated: true)
          }
          collectionView.scrollEnabled = false
          setPauseImageViewHidden(false)
          setBookmarkPlayheadHiddenForBookmarkedClip(true)
        }
      }
    }
    delegate?.playerWillBeginPlayback()
  }

  func playerDidEndPlayback() {
    for cell in collectionView.visibleCells() {
      let cell = cell as! ClipCollectionViewCell
      cell.setInPlayState(false, isCurrentPlayingClip: false, animated: true)
    }
    collectionView.scrollEnabled = true
    setPauseImageViewHidden(true)
    setBookmarkPlayheadHiddenForBookmarkedClip(false)
    delegate?.playerDidEndPlayback()
  }

  func playerWillPlayClip(clip: Clip) {
    scrollToClip(clip)
    if let thumbnailURL = clip.thumbnailURL {
      playerThumbnailImageView.hnk_setImageFromURL(thumbnailURL, format: Format<UIImage>(name: "original"))
    }
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
  func playerShouldBeginPlayback() -> Bool
  func playerWillBeginPlayback()
  func playerDidEndPlayback()
  func userDidAcceptPreviewClip(clip: Clip)
}