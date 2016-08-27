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
  let collectionView = TimelineCollectionView()
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
  var currentPage = 1

  var state = TimelineViewControllerState.Default {
    didSet {
      collectionView.scrollEnabled = (state != .Playing)
    }
  }

  private var defaultCellStateForCurrentState: ClipCollectionViewCellState {
    switch state {
    case .Playing: return .PlayingInactive
    case .Default: return .Default
    }
  }

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    getClipStream()

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

    collectionView.addPaginator(Paginator(postition: .Left, view: ColorSidePaginatorView()) {
      self.getClipStream(self.currentPage + 1)
    })
    collectionView.addPaginator(Paginator(postition: .Right, view: ColorSidePaginatorView()) {
      self.getClipStream()
    })

    let layout = collectionView.collectionViewLayout as! TimelineCollectionViewFlowLayout
    layout.delegate = self

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

  private func getClipStream(page: Int = 1) {
    currentPage = page
    let isRefresh = (page == 1)

    SnowballAPI.request(SnowballAPIRoute.ClipStream(page: page)).responseCollection { (response: Response<[Clip], NSError>) in
      switch response.result {
      case .Success(let clips):
        self.updateCollectionViewWithNewClips(clips, noMerge: isRefresh)
      case .Failure(let error): debugPrint(error)
      }

      if isRefresh {
        self.collectionView.rightPaginator?.endLoading()
      } else {
        self.collectionView.leftPaginator?.endLoading()
      }
    }
  }

  private func scrollToClip(clip: Clip) {
    if let index = clips.indexOf(clip) {
      collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0), atScrollPosition: .CenteredHorizontally, animated: true)
    }
  }

  private func updateCollectionViewWithNewClips(clips: [Clip], noMerge: Bool = false) {
    if noMerge {
      self.clips = clips.reverse()
      collectionView.reloadData()
    } else {
      let (newClips, duplicateClips, allClips) = ArrayDiff.mergeArrayByPrepending(clips.reverse(), toArray: self.clips)
      self.clips = allClips

      func clipsToIndexPaths(clips: [Clip]) -> [NSIndexPath] {
        return clips.map { (clip) -> NSIndexPath in
          let index = self.clips.indexOf(clip)!
          return NSIndexPath(forItem: index, inSection: 0)
        }
      }
      let insertIndexPaths = clipsToIndexPaths(newClips)
      let updateIndexPaths = clipsToIndexPaths(duplicateClips)
      collectionView.performBatchUpdates({
        self.collectionView.insertItemsAtIndexPaths(insertIndexPaths)
        self.collectionView.reloadItemsAtIndexPaths(updateIndexPaths)
      }, completion: nil)
    }
  }

  private func cellForClip(clip: Clip) -> ClipCollectionViewCell {
    let indexPath = NSIndexPath(forItem: clips.indexOf(clip)!, inSection: 0)
    return collectionView.cellForItemAtIndexPath(indexPath) as! ClipCollectionViewCell
  }

  private func clipForCell(cell: ClipCollectionViewCell) -> Clip {
    let index = collectionView.indexPathForCell(cell)!.row
    return clips[index]
  }

  private func updateStateForVisibleCells(stateBlock: ((cell: ClipCollectionViewCell) -> ClipCollectionViewCellState)) {
    for cell in collectionView.visibleCells() {
      let cell = cell as! ClipCollectionViewCell
      cell.setState(stateBlock(cell: cell), animated: true)
    }
  }

  private func updateStateForVisibleCellsWithPlayingClip(clip: Clip) {
    updateStateForVisibleCells { cell -> ClipCollectionViewCellState in
      if clip == self.clipForCell(cell) {
        return .PlayingActive
      }
      return self.defaultCellStateForCurrentState
    }
  }

  private func updateStateForVisibleCells() {
    updateStateForVisibleCells { _ -> ClipCollectionViewCellState in
      return self.defaultCellStateForCurrentState
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

// MARK: - TimelineViewControllerState
enum TimelineViewControllerState {
  case Default, Playing
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
    state = .Playing
    scrollToClip(clip)
    updateStateForVisibleCellsWithPlayingClip(clip)
  }

  func timelinePlayer(timelinePlayer: TimelinePlayer, didTransitionFromClip fromClip: Clip, toClip: Clip) {
    scrollToClip(toClip)
    updateStateForVisibleCellsWithPlayingClip(toClip)
  }

  func timelinePlayer(timelinePlayer: TimelinePlayer, didEndPlaybackWithLastClip clip: Clip) {
    state = .Default
    updateStateForVisibleCells()

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

// MARK: - TimelineCollectionViewFlowLayoutDelegate
extension TimelineViewController: TimelineCollectionViewFlowLayoutDelegate {
  func timelineCollectionViewFlowLayout(layout: TimelineCollectionViewFlowLayout, willFinalizeCollectionViewUpdates updates: [UICollectionViewUpdateItem]) {

    // Adjustments when loading secondary pages on the left
    if currentPage > 1 {
      let contentSizeBeforeAnimation = collectionView.contentSize
      let contentSizeAfterAnimation = layout.collectionViewContentSize()
      let xOffset = contentSizeAfterAnimation.width - contentSizeBeforeAnimation.width - ClipCollectionViewCell.defaultSize.width / 2
      if xOffset < 0 {
        collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
      } else {
        collectionView.setContentOffset(CGPoint(x: xOffset, y: 0), animated: false)
      }
    }
  }
}