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

  func cellForClip(clip: Clip) -> ClipCollectionViewCell? {
    if let index = timeline.indexOfClip(clip) {
      let indexPath = NSIndexPath(forItem: index, inSection: 0)
      return collectionView.cellForItemAtIndexPath(indexPath) as? ClipCollectionViewCell
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

  func timelinePlayerWillBeginPlayback(timelinePlayer: TimelinePlayer) {
    for cell in collectionView.visibleCells() {
      if let cell = cell as? ClipCollectionViewCell {
        cell.setState(ClipCollectionViewCellState.PlayingIdle, animated: true)
      }
    }
  }

  func timelinePlayer(timelinePlayer: TimelinePlayer, clipWillBeginPlayback clip: Clip) {
    let cell = cellForClip(clip)
    cell?.setState(ClipCollectionViewCellState.PlayingActive, animated: true)
    scrollToClip(clip, animated: true)
  }

  func timelinePlayer(timelinePlayer: TimelinePlayer, clipDidEndPlayback clip: Clip) {
    let cell = cellForClip(clip)
    cell?.setState(ClipCollectionViewCellState.PlayingIdle, animated: true)
  }

  func timelinePlayerDidEndPlayback(timelinePlayer: TimelinePlayer) {}
}

// MARK: - UICollectionViewDataSource
extension TimelineViewController: UICollectionViewDataSource {

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return timeline.clips.count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(ClipCollectionViewCell), forIndexPath: indexPath) as! ClipCollectionViewCell
    cell.configureForClip(timeline.clips[indexPath.row], state: stateForCellAtIndexPath(indexPath))
    return cell
  }
}

// MARK: - UICollectionViewDelegate
extension TimelineViewController: UICollectionViewDelegate {

  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let clip = timeline.clips[indexPath.row]
    player.play(clip)
  }
}