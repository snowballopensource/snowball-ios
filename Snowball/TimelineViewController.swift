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

class TimelineViewController: UIViewController, TimelineDelegate {

  // MARK: - Properties

  let timeline = Timeline()
  let player = TimelinePlayer()
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

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    timeline.delegate = self

    player.timeline = timeline
    player.delegate = self

    playerView.player = player

    collectionView.dataSource = self
    collectionView.delegate = self

    refresh()
  }

  override func loadView() {
    super.loadView()

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
    return ClipCollectionViewCellState.Default
  }

  // MARK: - Private

  private func cellForClip(clip: Clip) -> ClipCollectionViewCell? {
    if let index = timeline.indexOfClip(clip) {
      let indexPath = NSIndexPath(forItem: index, inSection: 0)
      return collectionView.cellForItemAtIndexPath(indexPath) as? ClipCollectionViewCell
    }
    return nil
  }

  private func clipForCell(cell: ClipCollectionViewCell) -> Clip? {
    if let indexPath = collectionView.indexPathForCell(cell) {
      return timeline.clips[indexPath.row]
    }
    return nil
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
  }

  func timeline(timeline: Timeline, didDeleteClip clip: Clip, atIndex index: Int) {
    let indexPath = NSIndexPath(forItem: index, inSection: 0)
    collectionView.deleteItemsAtIndexPaths([indexPath])
  }
}

// MARK: - TimelinePlayerDelegate
extension TimelineViewController: TimelinePlayerDelegate {

  // TODO: Break this out into three separate methods
  func timelinePlayer(timelinePlayer: TimelinePlayer, didTransitionFromClip fromClip: Clip?, toClip: Clip?) {
    if fromClip == nil && toClip == nil { return }
    if fromClip == nil && toClip != nil {
      // Just starting playback for the first time
      for cell in collectionView.visibleCells() {
        if let cell = cell as? ClipCollectionViewCell {
          if let initialClipCell = cellForClip(toClip!) {
            if cell == initialClipCell {
              cell.setState(ClipCollectionViewCellState.PlayingActive, animated: true)
            } else {
              cell.setState(ClipCollectionViewCellState.PlayingIdle, animated: true)
            }
          }
        }
      }
      scrollToClip(toClip!, animated: true)
    } else if fromClip != nil && toClip != nil {
      // Transition from a clip to a clip
      let fromCell = cellForClip(fromClip!)
      fromCell?.setState(ClipCollectionViewCellState.PlayingIdle, animated: true)
      let toCell = cellForClip(toClip!)
      toCell?.setState(ClipCollectionViewCellState.PlayingActive, animated: true)
      scrollToClip(toClip!, animated: true)
    } else if fromClip != nil && toClip == nil {
      // Playback ending
      for cell in collectionView.visibleCells() {
        if let cell = cell as? ClipCollectionViewCell {
          let indexPath = collectionView.indexPathForCell(cell)!
          cell.setState(stateForCellAtIndexPath(indexPath), animated: true)
          if stateForCellAtIndexPath(indexPath) == .PlayingIdle {
            println(stateForCellAtIndexPath(indexPath))
          }
        }
      }
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
    if player.playing {
      player.stop()
    } else {
      let clip = timeline.clips[indexPath.row]
      player.play(clip)
    }
  }
}

// MARK: - ClipCollectionViewCellDelegate
extension TimelineViewController: ClipCollectionViewCellDelegate {

  func userDidTapDeleteButtonForCell(cell: ClipCollectionViewCell) {
    let clip = clipForCell(cell)
    if clip?.user == User.currentUser, let clipID = clip?.id, let clip = clip {
      let alertController = UIAlertController(title: NSLocalizedString("Delete this clip?", comment: ""), message: NSLocalizedString("Are you sure you want to delete this clip?", comment: ""), preferredStyle: UIAlertControllerStyle.ActionSheet)
      alertController.addAction(UIAlertAction(title: NSLocalizedString("Don't Delete", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil))
      let deleteAction = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: UIAlertActionStyle.Destructive) { (action) in
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
    let clip = clipForCell(cell)
    if let user = clip?.user {
      navigationController?.pushViewController(ProfileTimelineViewController(user: user), animated: true)
    }
  }

  func userDidTapLikeButtonForCell(cell: ClipCollectionViewCell) {
    let clip = clipForCell(cell)
    if let clip = clip, let clipID = clip.id {
      if clip.liked {
        API.request(Router.UnlikeClip(clipID: clipID))
      } else {
        API.request(Router.LikeClip(clipID: clipID))
      }
      clip.liked = !clip.liked
    }
  }
}