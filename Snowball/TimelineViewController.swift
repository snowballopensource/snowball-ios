//
//  TimelineViewController.swift
//  Snowball
//
//  Created by James Martinez on 7/30/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import SwiftSpinner
import UIKit

// MARK: -

protocol TimelineFlowLayoutDelegate {
  func timelineFlowLayoutDidFinalizeCollectionViewUpdates(layout: TimelineFlowLayout)
}

class TimelineFlowLayout: UICollectionViewFlowLayout {
  var delegate: TimelineFlowLayoutDelegate?

  override func finalizeCollectionViewUpdates() {
    super.finalizeCollectionViewUpdates()

    delegate?.timelineFlowLayoutDidFinalizeCollectionViewUpdates(self)
  }
}

// MARK: -

class TimelineViewController: UIViewController, TimelineDelegate, TimelinePlayerDelegate, TimelineFlowLayoutDelegate {

  // MARK: - Properties

  var topView: SnowballTopView! // Must be set by subclass
  let timeline = Timeline()
  let player = TimelinePlayer()
  let playerView = TimelinePlayerView()
  let playerLoadingImageView = UIImageView()
  let playerLoadingIndicator = CircleLoadingIndicator()
  private class var collectionViewSideContentInset: CGFloat { return ClipCollectionViewCell.size.width * 4 }
  let collectionView: UICollectionView = {
    let flowLayout = TimelineFlowLayout()
    flowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.minimumLineSpacing = 0
    flowLayout.itemSize = ClipCollectionViewCell.size // TODO: maybe use autolayout to calculate?
    flowLayout.sectionInset = UIEdgeInsets(top: 0, left: collectionViewSideContentInset, bottom: 0, right: collectionViewSideContentInset)
    let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
    collectionView.backgroundColor = UIColor.whiteColor()
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.registerClass(ClipCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(ClipCollectionViewCell))
    return collectionView
    }()

  let playerControlSingleTapGestureRecognizer: UITapGestureRecognizer = {
    let gestureRecognizer = UITapGestureRecognizer()
    return gestureRecognizer
    }()
  let playerControlDoubleTapGestureRecognizer: UITapGestureRecognizer = {
    let gestureRecognizer = UITapGestureRecognizer()
    gestureRecognizer.numberOfTapsRequired = 2
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

  // At some time in the future, refactor pull to refresh/pull to scroll back to its own class...
  // TODO: BRING BACK PAGINATION / PULL TO REFRESH
  // var pullToRefreshTriggered = false

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    let collectionViewLayout = collectionView.collectionViewLayout as! TimelineFlowLayout
    collectionViewLayout.delegate = self

    view.backgroundColor = UIColor.whiteColor()
    view.clipsToBounds = true

    timeline.delegate = self

    player.timeline = timeline
    player.delegate = self

    playerView.player = player

    collectionView.dataSource = self
    collectionView.delegate = self

    playerControlSingleTapGestureRecognizer.addTarget(self, action: "userDidTapPlayerControlGestureRecognizer:")
    playerView.addGestureRecognizer(playerControlSingleTapGestureRecognizer)

    playerControlDoubleTapGestureRecognizer.addTarget(self, action: "userDidDoubleTapPlayerControlGestureRecognizer:")
    playerView.addGestureRecognizer(playerControlDoubleTapGestureRecognizer)
    playerControlSingleTapGestureRecognizer.requireGestureRecognizerToFail(playerControlDoubleTapGestureRecognizer)

    playerControlSwipeLeftGestureRecognizer.addTarget(self, action: "userDidSwipePlayerControlGestureRecognizerLeft:")
    view.addGestureRecognizer(playerControlSwipeLeftGestureRecognizer)
    playerControlSwipeRightGestureRecognizer.addTarget(self, action: "userDidSwipePlayerControlGestureRecognizerRight:")
    view.addGestureRecognizer(playerControlSwipeRightGestureRecognizer)

    NSNotificationCenter.defaultCenter().addObserver(self, selector: "refresh", name: UIApplicationWillEnterForegroundNotification, object: nil)
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    refresh()
  }

  override func loadView() {
    super.loadView()

    view.addSubview(playerView)
    constrain(playerView) { (playerView) in
      playerView.left == playerView.superview!.left
      playerView.top == playerView.superview!.top
      playerView.right == playerView.superview!.right
      playerView.height == playerView.width
    }

    view.addSubview(playerLoadingImageView)
    constrain(playerLoadingImageView) { (playerLoadingImageView) in
      playerLoadingImageView.left == playerLoadingImageView.superview!.left
      playerLoadingImageView.top == playerLoadingImageView.superview!.top
      playerLoadingImageView.right == playerLoadingImageView.superview!.right
      playerLoadingImageView.height == playerLoadingImageView.width
    }

    view.addSubview(playerLoadingIndicator)
    constrain(playerLoadingIndicator, playerLoadingImageView) { (playerLoadingIndicator, playerLoadingImageView) in
      playerLoadingIndicator.centerX == playerLoadingImageView.centerX
      playerLoadingIndicator.bottom == playerLoadingImageView.bottom - 15
      playerLoadingIndicator.width == 15
      playerLoadingIndicator.height == 15
    }

    view.addSubview(collectionView)
    constrain(collectionView, playerView) { (collectionView, playerView) in
      collectionView.left == collectionView.superview!.left - TimelineViewController.collectionViewSideContentInset
      collectionView.top == playerView.bottom
      collectionView.right == collectionView.superview!.right + TimelineViewController.collectionViewSideContentInset
      collectionView.bottom == collectionView.superview!.bottom
    }

    playerView.addGestureRecognizer(playerControlSingleTapGestureRecognizer)
    playerView.addGestureRecognizer(playerControlDoubleTapGestureRecognizer)
    view.addGestureRecognizer(playerControlSwipeLeftGestureRecognizer)
    view.addGestureRecognizer(playerControlSwipeRightGestureRecognizer)
  }

  // MARK: - Internal

  // -loadPage is designed to be subclassed and never called outside of -refresh or -loadPreviousPage
  func loadPage(page: Int) {}

  final func refresh() {
    print("Refresh")
    loadPage(1)
  }

  final func loadPreviousPage() {
    print("Previous")
    loadPage(timeline.currentPage + 1)
  }

  func scrollToClip(clip: Clip, animated: Bool = true) {
    if let index = timeline.indexOfClip(clip) {
      let indexPath = NSIndexPath(forItem: index, inSection: 0)
      collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: animated)
    }
  }

  func stateForCellAtIndexPath(indexPath: NSIndexPath) -> ClipCollectionViewCellState {
    let clip = timeline.clips[indexPath.row]
    if player.playing {
      if clip == player.currentClip {
        return ClipCollectionViewCellState.PlayingActive
      }
      return ClipCollectionViewCellState.PlayingIdle
    }
    var state = ClipCollectionViewCellState.Default
    switch(clip.state) {
    case ClipState.Default: state = ClipCollectionViewCellState.Default
    case ClipState.PendingUpload: state = ClipCollectionViewCellState.PendingUpload
    case ClipState.Uploading: state = ClipCollectionViewCellState.Uploading
    case ClipState.UploadFailed: state = ClipCollectionViewCellState.UploadFailed
    }
    return state
  }

  func cellForClip(clip: Clip) -> ClipCollectionViewCell? {
    if let index = timeline.indexOfClip(clip) {
      let indexPath = NSIndexPath(forItem: index, inSection: 0)
      return collectionView.cellForItemAtIndexPath(indexPath) as? ClipCollectionViewCell
    }
    return nil
  }

  func clipForCell(cell: ClipCollectionViewCell) -> Clip? {
    if let indexPath = collectionView.indexPathForCell(cell) {
      return timeline.clips[indexPath.row]
    }
    return nil
  }

  func setInterfaceFocused(focused: Bool) {
    topView.setHidden(focused, animated: true)
    collectionView.scrollEnabled = !focused
  }

  // This next part is the TimelineDelegate implementation. It's ugly because as of Swift 1.2 we are not allowed to
  // override certain functions/types in an extension. It's weird and I don't get it, but oh well.
  // When changing it back to an extension, don't forget to remove the <TimelineDelegate> from the
  // class declaration above.

  // MARK: - TimelineDelegate
  // extension TimelineViewController: TimelineDelegate {

  func timelineClipsDidLoadFromCache() {
    collectionView.reloadData()
  }

  func timeline(timeline: Timeline, didUpdateClipAtIndex index: Int) {
    resetStateOnVisibleCells()
  }

  func timeline(timeline: Timeline, didInsertClipAtIndex index: Int) {
    collectionView.insertItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
    resetStateOnVisibleCells()
  }

  func timeline(timeline: Timeline, didDeleteClipAtIndex index: Int) {
    collectionView.deleteItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
    resetStateOnVisibleCells()
  }

  func timeline(timeline: Timeline, didInsertClipsAtIndexes insertIndexes: [Int], didDeleteClipsAtIndexes deleteIndexes: [Int]) {
    collectionView.performBatchUpdates({
      self.collectionView.insertItemsAtIndexPaths(insertIndexes.map({ NSIndexPath(forItem: $0, inSection: 0) }))
      self.collectionView.deleteItemsAtIndexPaths(deleteIndexes.map({ NSIndexPath(forItem: $0, inSection: 0) }))
      }) { _ in
        self.resetStateOnVisibleCells()
    }
  }

  // This next part is the TimelinePlayerDelegate implementation. For details as to why it's here,
  // see the large comment block above the TimelineDelegate implementation above.

  // MARK: - TimelinePlayerDelegate
  // extension TimelineViewController: TimelinePlayerDelegate {

  func timelinePlayer(timelinePlayer: TimelinePlayer, shouldBeginPlayingWithClip clip: Clip) -> Bool {
    return true
  }

  func timelinePlayer(timelinePlayer: TimelinePlayer, didBeginPlayingWithClip clip: Clip) {
    Analytics.track("Watch Clip")
    setInterfaceFocused(true)
    playerView.hidden = false
    for cell in collectionView.visibleCells() {
      if let cell = cell as? ClipCollectionViewCell {
        if let initialClipCell = cellForClip(clip) {
          if cell == initialClipCell {
            cell.setState(ClipCollectionViewCellState.PlayingActive, animated: true)
          } else {
            cell.setState(ClipCollectionViewCellState.PlayingIdle, animated: true)
          }
        }
      }
    }
    scrollToClip(clip, animated: true)
  }

  func timelinePlayer(timelinePlayer: TimelinePlayer, didTransitionFromClip fromClip: Clip, toClip: Clip) {
    Analytics.track("Watch Clip")
    let fromCell = cellForClip(fromClip)
    fromCell?.setState(ClipCollectionViewCellState.PlayingIdle, animated: true)
    let toCell = cellForClip(toClip)
    toCell?.setState(ClipCollectionViewCellState.PlayingActive, animated: true)
    scrollToClip(toClip, animated: true)
  }

  func timelinePlayer(timelinePlayer: TimelinePlayer, didEndPlayingWithLastClip lastClip: Clip) {
    setInterfaceFocused(false)
    playerView.hidden = true
    endBuffering()
    for cell in collectionView.visibleCells() {
      if let cell = cell as? ClipCollectionViewCell {
        resetStateForCell(cell)
        timeline.bookmarkedClip = lastClip
      }
    }
  }

  func timelinePlayerDidBeginBuffering(timelinePlayer: TimelinePlayer) {
    playerLoadingIndicator.startAnimating(withDelay: true)
    playerLoadingImageView.backgroundColor = UIColor.SnowballColor.grayColor
    if let thumbnailURLString = timelinePlayer.currentClip?.thumbnailURL, thumbnailURL = NSURL(string: thumbnailURLString) {
      playerLoadingImageView.setImageFromURL(thumbnailURL, animated: false)
    }
  }

  func timelinePlayerDidEndBuffering(timelinePlayer: TimelinePlayer) {
    endBuffering()
  }

  // MARK: - TimelineFlowLayoutDelegate
  func timelineFlowLayoutDidFinalizeCollectionViewUpdates(layout: TimelineFlowLayout) {}

  // MARK: - Private

  private func endBuffering() {
    playerLoadingImageView.backgroundColor = nil
    playerLoadingIndicator.stopAnimating()
    playerLoadingImageView.cancelAsyncImageLoad()
    playerLoadingImageView.image = nil
  }

  @objc private func applicationWillEnterForeground() {
    refresh()
  }

  @objc private func userDidTapPlayerControlGestureRecognizer(recognizer: UITapGestureRecognizer) {
    if player.playing {
      player.stop()
    }
  }

  @objc private func userDidDoubleTapPlayerControlGestureRecognizer(recognizer: UITapGestureRecognizer) {
    if let clip = player.currentClip, cell = cellForClip(clip) {
      userDidTapLikeButtonForCell(cell)
    }
  }

  @objc private func userDidSwipePlayerControlGestureRecognizerLeft(recognizer: UISwipeGestureRecognizer) {
    if player.playing {
      player.next()
    }
  }

  @objc private func userDidSwipePlayerControlGestureRecognizerRight(recognizer: UISwipeGestureRecognizer) {
    if player.playing {
      player.previous()
    }
  }

  private func resetStateOnVisibleCells() {
    for cell in collectionView.visibleCells() {
      if let cell = cell as? ClipCollectionViewCell {
        resetStateForCell(cell)
      }
    }
  }

  private func resetStateForCell(cell: ClipCollectionViewCell) {
    if let indexPath = collectionView.indexPathForCell(cell) {
      cell.setState(stateForCellAtIndexPath(indexPath), animated: true)
    }
  }
}

// MARK: - UICollectionViewDataSource
extension TimelineViewController: UICollectionViewDataSource {

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return timeline.clips.count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(ClipCollectionViewCell), forIndexPath: indexPath) as! ClipCollectionViewCell
    cell.delegate = self
    cell.configureForClip(timeline.clips[indexPath.row], state: stateForCellAtIndexPath(indexPath))
    return cell
  }
}

// MARK: - UICollectionViewDelegate
extension TimelineViewController: UICollectionViewDelegate {

  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let clip = timeline.clips[indexPath.row]
    if clip.state == ClipState.Default {
      if player.playing {
        if let playingClip = player.currentClip {
          if playingClip != clip {
            if timeline.clips.indexOf(playingClip) < timeline.clips.indexOf(clip) {
              player.next()
            } else {
              player.previous()
            }
            return
          }
        }
        player.stop()
      } else {
        player.play(clip)
      }
    }
  }
}

// MARK: - UIScrollViewDelegate
// TODO: BRING BACK PAGINATION / PULL TO REFRESH
//extension TimelineViewController: UIScrollViewDelegate {
//
//  func scrollViewDidScroll(scrollView: UIScrollView) {
//    let pullToLoadDistance: CGFloat = 55
//    let xOffset = scrollView.contentOffset.x
//    if xOffset < 0 && xOffset < -pullToLoadDistance {
//      beginLoadIfAppropriate(scrollView) {
//        self.loadPreviousPage()
//      }
//    } else if (xOffset + scrollView.bounds.width) > scrollView.contentSize.width + pullToLoadDistance {
//      beginLoadIfAppropriate(scrollView) {
//        self.refresh()
//      }
//    }
//  }
//
//  private func beginLoadIfAppropriate(scrollView: UIScrollView, load: () -> Void) {
//    if scrollView.tracking && timeline.loadingState == TimelineLoadingState.Idle {
//      pullToRefreshTriggered = true
//    } else if !scrollView.tracking && pullToRefreshTriggered {
//      pullToRefreshTriggered = false
//      load()
//    }
//  }
//}

// MARK: - ClipCollectionViewCellDelegate
extension TimelineViewController: ClipCollectionViewCellDelegate {

  func userDidShowOptionsGestureForCell(cell: ClipCollectionViewCell) {
    authenticateUser(
      afterSuccessfulAuthentication: {
        self.refresh()
      }, whenAlreadyAuthenticated: {
        cell.setState(.Options, animated: true)
    })
  }

  func userDidHideOptionsGestureForCell(cell: ClipCollectionViewCell) {
    resetStateForCell(cell)
  }

  func userDidTapAddButtonForCell(cell: ClipCollectionViewCell) {}

  func userDidTapDeleteButtonForCell(cell: ClipCollectionViewCell) {
    let clip = clipForCell(cell)
    if clip?.user == User.currentUser, let clip = clip {
      let alert = UIAlertController(title: NSLocalizedString("Delete this clip?", comment: ""), message: NSLocalizedString("Are you sure you want to delete this clip?", comment: ""), preferredStyle: UIAlertControllerStyle.ActionSheet)
      alert.addAction(UIAlertAction(title: NSLocalizedString("Don't Delete", comment: ""), style: UIAlertActionStyle.Cancel) { action in
        self.resetStateForCell(cell)
        })
      alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: UIAlertActionStyle.Destructive) { (action) in
        if let clipID = clip.id {
          SwiftSpinner.show(NSLocalizedString("Deleting...", comment: ""))
          SnowballAPI.request(.DeleteClip(clipID: clipID)) { response in
            SwiftSpinner.hide()
            switch response {
            case .Success: self.timeline.deleteClip(clip)
            case .Failure(let error): error.alertUser()
            }
          }
        } else {
          self.timeline.deleteClip(clip)
        }
        })
      alert.display()
    }
  }

  func userDidTapFlagButtonForCell(cell: ClipCollectionViewCell) {
    let clip = self.clipForCell(cell)
    if let clipID = clip?.id, let clip = clip {
      let alert = UIAlertController(title: NSLocalizedString("Flag this clip?", comment: ""), message: NSLocalizedString("Are you sure you want to flag this clip?", comment: ""), preferredStyle: UIAlertControllerStyle.ActionSheet)
      alert.addAction(UIAlertAction(title: NSLocalizedString("Don't Flag", comment: ""), style: UIAlertActionStyle.Cancel) { action in
        self.resetStateForCell(cell)
        })
      let deleteAction = UIAlertAction(title: NSLocalizedString("Flag", comment: ""), style: UIAlertActionStyle.Destructive) { (action) in
        SwiftSpinner.show(NSLocalizedString("Flagging...", comment: ""))
        SnowballAPI.request(.FlagClip(clipID: clipID)) { response in
          SwiftSpinner.hide()
          switch response {
          case .Success: self.timeline.deleteClip(clip)
          case .Failure(let error): error.alertUser()
          }
        }
      }
      alert.addAction(deleteAction)
      alert.display()
    }
  }

  func userDidTapUserButtonForCell(cell: ClipCollectionViewCell) {
    authenticateUser(
      afterSuccessfulAuthentication: {
        self.refresh()
      }, whenAlreadyAuthenticated: {
        if !self.player.playing {
          let clip = self.clipForCell(cell)
          if let user = clip?.user {
            self.navigationController?.pushViewController(ProfileTimelineViewController(user: user), animated: true)
          }
        }
    })
  }

  func userDidTapLikeButtonForCell(cell: ClipCollectionViewCell) {
    authenticateUser(
      afterSuccessfulAuthentication: {
        self.refresh()
      }, whenAlreadyAuthenticated: {
        let clip = self.clipForCell(cell)
        if let clip = clip, let clipID = clip.id, let user = clip.user, let currentUser = User.currentUser {
          if user != currentUser {
            clip.liked = !clip.liked.boolValue
            cell.setClipLiked(clip.liked.boolValue, animated: true)
            do { try clip.managedObjectContext?.save() } catch {}
            if clip.liked.boolValue {
              Analytics.track("Like Clip")
              SnowballAPI.request(.LikeClip(clipID: clipID)) { response in
                SwiftSpinner.hide()
                switch response {
                case .Success: break
                case .Failure(let error):
                  error.alertUser()
                  clip.liked = !clip.liked.boolValue
                  cell.setClipLiked(clip.liked.boolValue, animated: true)
                  do { try clip.managedObjectContext?.save() } catch {}
                }
              }
            } else {
              Analytics.track("Unlike Clip")
              SnowballAPI.request(.UnlikeClip(clipID: clipID)) { response in
                SwiftSpinner.hide()
                switch response {
                case .Success: break
                case .Failure(let error):
                  error.alertUser()
                  clip.liked = !clip.liked.boolValue
                  cell.setClipLiked(clip.liked.boolValue, animated: true)
                  do { try clip.managedObjectContext?.save() } catch {}
                }
              }
            }
          }
        }
    })
  }

  func userDidTapUploadRetryButtonForCell(cell: ClipCollectionViewCell) {}
}