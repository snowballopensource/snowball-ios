//
//  TimelineViewController.swift
//  Snowball
//
//  Created by James Martinez on 7/30/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class TimelineViewController: UIViewController {

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
}

// MARK: - TimelineDelegate
extension TimelineViewController: TimelineDelegate {

  func timelineClipsDidChange() {
    collectionView.reloadData()
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
    if clip?.user == User.currentUser, let clipID = clip?.id {
      API.request(Router.DeleteClip(clipID: clipID)).responseJSON { (request, response, JSON, error) in
        if let error = error {
          println(error)
          // TODO: Display the error
        }
      }
    }
  }

  func userDidTapFlagButtonForCell(cell: ClipCollectionViewCell) {
    let clip = clipForCell(cell)
    // TODO: Flag the clip
    println("flag clip")
  }

  func userDidTapUserButtonForCell(cell: ClipCollectionViewCell) {
    let clip = clipForCell(cell)
    if let user = clip?.user {
      navigationController?.pushViewController(ProfileTimelineViewController(user: user), animated: true)
    }
  }

  func userDidTapLikeButtonForCell(cell: ClipCollectionViewCell) {
    let clip = clipForCell(cell)
    // TODO: Like the clip
    println("like clip")
  }
}