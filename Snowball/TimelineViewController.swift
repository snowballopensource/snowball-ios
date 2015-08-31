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

class TimelineViewController: UIViewController, TimelineDelegate, TimelinePlayerDelegate {

  // MARK: - Properties

  var topView: SnowballTopView! // Must be set by subclass
  let timeline = Timeline()
  let player = TimelinePlayer()
  let playerLoadingImageView = UIImageView()
  let playerView = TimelinePlayerView()
  let collectionView: UICollectionView = {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.minimumLineSpacing = 0
    flowLayout.itemSize = ClipCollectionViewCell.size // TODO: maybe use autolayout to calculate?
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

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.whiteColor()

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

    refresh()
  }

  override func loadView() {
    super.loadView()

    view.addSubview(playerLoadingImageView)
    layout(playerLoadingImageView) { (playerLoadingImageView) in
      playerLoadingImageView.left == playerLoadingImageView.superview!.left
      playerLoadingImageView.top == playerLoadingImageView.superview!.top
      playerLoadingImageView.right == playerLoadingImageView.superview!.right
      playerLoadingImageView.height == playerLoadingImageView.width
    }

    view.addSubview(playerView)
    layout(playerView) { (playerView) in
      playerView.left == playerView.superview!.left
      playerView.top == playerView.superview!.top
      playerView.right == playerView.superview!.right
      playerView.height == playerView.width
    }

    view.addSubview(collectionView)
    layout(collectionView, playerView) { (collectionView, playerView) in
      collectionView.left == collectionView.superview!.left
      collectionView.top == playerView.bottom
      collectionView.right == collectionView.superview!.right
      collectionView.bottom == collectionView.superview!.bottom
    }

    playerView.addGestureRecognizer(playerControlSingleTapGestureRecognizer)
    playerView.addGestureRecognizer(playerControlDoubleTapGestureRecognizer)
    view.addGestureRecognizer(playerControlSwipeLeftGestureRecognizer)
    view.addGestureRecognizer(playerControlSwipeRightGestureRecognizer)
  }

  // MARK: - Internal

  func refresh() {}

  func scrollToClip(clip: Clip, animated: Bool = true) {
    if let index = timeline.indexOfClip(clip) {
      let indexPath = NSIndexPath(forItem: index, inSection: 0)
      collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: animated)
    }
  }

  func stateForCellAtIndexPath(indexPath: NSIndexPath) -> ClipCollectionViewCellState {
    if player.playing {
      return ClipCollectionViewCellState.PlayingIdle
    }
    let clip = timeline.clips[indexPath.row]
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

  func timelineClipsDidLoad() {
    collectionView.reloadData()
  }

  func timeline(timeline: Timeline, didInsertClip clip: Clip, atIndex index: Int) {
    let indexPath = NSIndexPath(forItem: index, inSection: 0)
    collectionView.insertItemsAtIndexPaths([indexPath])
    resetStateOnVisibleCells()
  }

  func timeline(timeline: Timeline, didUpdateClip clip: Clip, atIndex index: Int) {
    resetStateOnVisibleCells()
  }

  func timeline(timeline: Timeline, didDeleteClip clip: Clip, atIndex index: Int) {
    let indexPath = NSIndexPath(forItem: index, inSection: 0)
    collectionView.deleteItemsAtIndexPaths([indexPath])
    resetStateOnVisibleCells()
  }

  // This next part is the TimelinePlayerDelegate implementation. For details as to why it's here,
  // see the large comment block above the TimelineDelegate implementation above.

  // MARK: - TimelinePlayerDelegate
  // extension TimelineViewController: TimelinePlayerDelegate {

  func timelinePlayer(timelinePlayer: TimelinePlayer, shouldBeginPlayingWithClip clip: Clip) -> Bool {
    return true
  }

  func timelinePlayer(timelinePlayer: TimelinePlayer, didBeginPlayingWithClip clip: Clip) {
    setInterfaceFocused(true)
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
    prepareToPlayClip(clip)
  }

  func timelinePlayer(timelinePlayer: TimelinePlayer, didTransitionFromClip fromClip: Clip, toClip: Clip) {
    let fromCell = cellForClip(fromClip)
    fromCell?.setState(ClipCollectionViewCellState.PlayingIdle, animated: true)
    let toCell = cellForClip(toClip)
    toCell?.setState(ClipCollectionViewCellState.PlayingActive, animated: true)
    prepareToPlayClip(toClip)
  }

  func timelinePlayer(timelinePlayer: TimelinePlayer, didEndPlayingLastClip lastClip: Clip) {
    setInterfaceFocused(false)
    for cell in collectionView.visibleCells() {
      if let cell = cell as? ClipCollectionViewCell {
        let indexPath = collectionView.indexPathForCell(cell)!
        cell.setState(stateForCellAtIndexPath(indexPath), animated: true)
        timeline.bookmarkedClip = lastClip
      }
    }
  }

  // MARK: - Private

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
      if let currentClip = player.currentClip, let nextClip = timeline.clipAfterClip(currentClip) {
        player.play(nextClip)
      }
    }
  }

  @objc private func userDidSwipePlayerControlGestureRecognizerRight(recognizer: UISwipeGestureRecognizer) {
    if player.playing {
      if let currentClip = player.currentClip, let previousClip = timeline.clipBeforeClip(currentClip) {
        player.play(previousClip)
      }
    }
  }

  private func resetStateOnVisibleCells() {
    for cell in collectionView.visibleCells() {
      if let cell = cell as? ClipCollectionViewCell, cellIndexPath = collectionView.indexPathForCell(cell) {
        cell.setState(stateForCellAtIndexPath(cellIndexPath), animated: true)
      }
    }
  }

  private func prepareToPlayClip(clip: Clip) {
    if let thumbnailURLString = clip.thumbnailURL, thumbnailURL = NSURL(string: thumbnailURLString) {
      playerLoadingImageView.setImageFromURL(thumbnailURL)
    }
    scrollToClip(clip, animated: true)
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
            player.play(clip)
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

// MARK: - ClipCollectionViewCellDelegate
extension TimelineViewController: ClipCollectionViewCellDelegate {

  func userDidShowOptionsGestureForCell(cell: ClipCollectionViewCell) {
    cell.setState(.Options, animated: true)
  }

  func userDidHideOptionsGestureForCell(cell: ClipCollectionViewCell) {
    if let indexPath = collectionView.indexPathForCell(cell) {
      cell.setState(stateForCellAtIndexPath(indexPath), animated: true)
    }
  }

  func userDidTapAddButtonForCell(cell: ClipCollectionViewCell) {}

  func userDidTapDeleteButtonForCell(cell: ClipCollectionViewCell) {
    let clip = clipForCell(cell)
    if clip?.user == User.currentUser, let clip = clip {
      let alertController = UIAlertController(title: NSLocalizedString("Delete this clip?", comment: ""), message: NSLocalizedString("Are you sure you want to delete this clip?", comment: ""), preferredStyle: UIAlertControllerStyle.ActionSheet)
      alertController.addAction(UIAlertAction(title: NSLocalizedString("Don't Delete", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil))
      let deleteAction = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: UIAlertActionStyle.Destructive) { (action) in
        if let clipID = clip.id {
          SwiftSpinner.show(NSLocalizedString("Deleting...", comment: ""))
          API.request(Router.DeleteClip(clipID: clipID)).response { (request, response, data, error) in
            SwiftSpinner.hide()
            if let error = error {
              println(error)
              // TOOD: Display the error
            } else {
              self.timeline.deleteClip(clip)
            }
          }
        } else {
          self.timeline.deleteClip(clip)
        }
      }
      alertController.addAction(deleteAction)
      presentViewController(alertController, animated: true, completion: nil)
    }
  }

  func userDidTapFlagButtonForCell(cell: ClipCollectionViewCell) {
    let clip = clipForCell(cell)
    if let clipID = clip?.id, let clip = clip {
      let alertController = UIAlertController(title: NSLocalizedString("Flag this clip?", comment: ""), message: NSLocalizedString("Are you sure you want to flag this clip?", comment: ""), preferredStyle: UIAlertControllerStyle.ActionSheet)
      alertController.addAction(UIAlertAction(title: NSLocalizedString("Don't Flag", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil))
      let deleteAction = UIAlertAction(title: NSLocalizedString("Flag", comment: ""), style: UIAlertActionStyle.Destructive) { (action) in
        SwiftSpinner.show(NSLocalizedString("Flagging...", comment: ""))
        API.request(Router.FlagClip(clipID: clipID)).response { (request, response, data, error) in
          SwiftSpinner.hide()
          if let error = error {
            println(error)
            // TOOD: Display the error
          } else {
            self.timeline.deleteClip(clip)
          }
        }
      }
      alertController.addAction(deleteAction)
      presentViewController(alertController, animated: true, completion: nil)
    }
  }

  func userDidTapUserButtonForCell(cell: ClipCollectionViewCell) {
    if !player.playing {
      let clip = clipForCell(cell)
      if let user = clip?.user {
        navigationController?.pushViewController(ProfileTimelineViewController(user: user), animated: true)
      }
    }
  }

  func userDidTapLikeButtonForCell(cell: ClipCollectionViewCell) {
    let clip = clipForCell(cell)
    if let clip = clip, let clipID = clip.id, let user = clip.user, let currentUser = User.currentUser {
      if user != currentUser {
        clip.liked = !clip.liked.boolValue
        cell.setClipLiked(clip.liked.boolValue, animated: true)
        if clip.liked.boolValue {
          Analytics.track("Like Clip")
          API.request(Router.LikeClip(clipID: clipID))
        } else {
          Analytics.track("Unlike Clip")
          API.request(Router.UnlikeClip(clipID: clipID))
        }
      }
    }
  }

  func userDidTapUploadRetryButtonForCell(cell: ClipCollectionViewCell) {}
}