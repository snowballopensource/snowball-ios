//
//  TimelineViewController.swift
//  Snowball
//
//  Created by James Martinez on 8/8/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Alamofire
import UIKit

class TimelineViewController: UIViewController {

  // MARK: Properties

  var clips = [Clip]()
  let player = TimelinePlayer()
  let playerView = PlayerView()
  let collectionView: UICollectionView = {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = .Horizontal
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.minimumLineSpacing = 0
    flowLayout.itemSize = ClipCollectionViewCell.defaultSize
    let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
    collectionView.registerClass(ClipCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(ClipCollectionViewCell))
    collectionView.showsHorizontalScrollIndicator = false
    return collectionView
  }()
  let previousClipGestureRecognizer: UISwipeGestureRecognizer = {
    let gestureRecognizer = UISwipeGestureRecognizer()
    gestureRecognizer.direction = .Right
    return gestureRecognizer
  }()
  let nextClipGestureRecognizer: UISwipeGestureRecognizer = {
    let gestureRecognizer = UISwipeGestureRecognizer()
    gestureRecognizer.direction = .Left
    return gestureRecognizer
  }()

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    SnowballAPI.request(SnowballAPIRoute.ClipStream).responseCollection { (response: Response<[Clip], NSError>) in
      switch response.result {
      case .Success(let clips):
        self.clips = clips.reverse()
        self.collectionView.reloadData()
      case .Failure(let error): debugPrint(error)
      }
    }

    view.backgroundColor = UIColor.whiteColor()

    player.dataSource = self
    player.delegate = self
    playerView.player = player

    view.addSubview(playerView)
    playerView.translatesAutoresizingMaskIntoConstraints = false
    playerView.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
    playerView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
    playerView.rightAnchor.constraintEqualToAnchor(view.rightAnchor).active = true
    playerView.heightAnchor.constraintEqualToAnchor(view.widthAnchor).active = true

    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.addGestureRecognizer(previousClipGestureRecognizer)
    collectionView.addGestureRecognizer(nextClipGestureRecognizer)
    previousClipGestureRecognizer.addTarget(self, action: #selector(TimelineViewController.previousClipGestureRecognizerSwiped))
    nextClipGestureRecognizer.addTarget(self, action: #selector(TimelineViewController.nextClipGestureRecognizerSwiped))

    view.addSubview(collectionView)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
    collectionView.topAnchor.constraintEqualToAnchor(playerView.bottomAnchor).active = true
    collectionView.rightAnchor.constraintEqualToAnchor(view.rightAnchor).active = true
    collectionView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
  }

  override func prefersStatusBarHidden() -> Bool {
    return true
  }

  // MARK: Private

  private func scrollToClip(clip: Clip) {
    if let index = clips.indexOf(clip) {
      collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0), atScrollPosition: .CenteredHorizontally, animated: true)
    }
  }

  // MARK: Actions

  @objc private func previousClipGestureRecognizerSwiped() {
    player.previous()
  }

  @objc private func nextClipGestureRecognizerSwiped() {
    player.next()
  }
}

// MARK: - TimelinePlayerDataSource
extension TimelineViewController: TimelinePlayerDataSource {
  func numberOfClipsInTimelinePlayer(player: TimelinePlayer) -> Int {
    return clips.count
  }

  func timelinePlayer(player: TimelinePlayer, clipAtIndex index: Int) -> Clip {
    return clips[index]
  }

  func timelinePlayer(player: TimelinePlayer, indexOfClip clip: Clip) -> Int? {
    return clips.indexOf(clip)
  }
}

// MARK: - TimelinePlayerDeleate
extension TimelineViewController: TimelinePlayerDelegate {
  func timelinePlayer(timelinePlayer: TimelinePlayer, willBeginPlaybackWithFirstClip clip: Clip) {
    print("begin")
    collectionView.scrollEnabled = false
    scrollToClip(clip)
  }

  func timelinePlayer(timelinePlayer: TimelinePlayer, didTransitionFromClip fromClip: Clip, toClip: Clip) {
    print("transition")
    scrollToClip(toClip)
  }

  func timelinePlayer(timelinePlayer: TimelinePlayer, didEndPlaybackWithLastClip clip: Clip) {
    print("done")
    collectionView.scrollEnabled = true
  }
}

// MARK: - UICollectionViewDataSource
extension TimelineViewController: UICollectionViewDataSource {
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return clips.count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(ClipCollectionViewCell), forIndexPath: indexPath) as! ClipCollectionViewCell
    let clip = clips[indexPath.row]
    cell.configureForClip(clip)
    return cell
  }
}

// MARK: - UICollectionViewDelegate
extension TimelineViewController: UICollectionViewDelegate {
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let clip = clips[indexPath.row]
    if let playerItem = player.currentItem as? ClipPlayerItem {
      if playerItem.clip == clip {
        player.stop()
      } else {
        player.playClip(clip)
      }
    } else {
      player.playClip(clip)
    }
  }
}