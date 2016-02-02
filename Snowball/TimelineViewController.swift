//
//  TimelineViewController.swift
//  Snowball
//
//  Created by James Martinez on 12/10/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import RealmSwift
import SwiftFetchedResultsController
import UIKit

class TimelineViewController: UIViewController {

  // MARK: Properties

  let timeline: Timeline
  let player: TimelinePlayer
  let playerView = PlayerView()
  let timelineCollectionView = TimelineCollectionView()
  let fetchedResultsController: FetchedResultsController<Clip>
  var collectionViewUpdates = [NSBlockOperation]()

  // MARK: Initializers

  init(timelineType: TimelineType) {
    timeline = Timeline(type: timelineType)
    player = TimelinePlayer(timeline: timeline)

    let fetchRequest = FetchRequest<Clip>(realm: Database.realm, predicate: timeline.predicate)
    fetchRequest.sortDescriptors = timeline.sortDescriptors
    fetchedResultsController = FetchedResultsController<Clip>(fetchRequest: fetchRequest, sectionNameKeyPath: nil, cacheName: nil)

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "top-friends"), style: .Plain, target: self, action: "leftBarButtonItemPressed")
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "top-flip-camera"), style: .Plain, target: self, action: "rightBarButtonItemPressed")

    view.addSubview(playerView)
    constrain(playerView) { playerView in
      playerView.left == playerView.superview!.left
      playerView.top == playerView.superview!.top
      playerView.right == playerView.superview!.right
      playerView.height == playerView.superview!.width
    }
    player.delegate = self
    playerView.player = player

    view.addSubview(timelineCollectionView)
    constrain(timelineCollectionView, playerView) { timelineCollectionView, playerView in
      timelineCollectionView.left == timelineCollectionView.superview!.left
      timelineCollectionView.top == playerView.bottom
      timelineCollectionView.right == timelineCollectionView.superview!.right
      timelineCollectionView.bottom == timelineCollectionView.superview!.bottom
    }
    timelineCollectionView.dataSource = self
    timelineCollectionView.enablePullToLoadWithDelegate(self)

    fetchedResultsController.delegate = self
    fetchedResultsController.performFetch()
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    timeline.requestRefreshOfClips()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    scrollToBookmarkedClip(false)
  }

  // MARK: - Private

  private func scrollToBookmarkedClip(animated: Bool) {
    if let bookmarkedClip = timeline.bookmarkedClip {
      scrollToCellForClip(bookmarkedClip, animated: animated)
    }
  }

  private func scrollToCellForClip(clip: Clip, animated: Bool) {
    if let indexPath = fetchedResultsController.indexPathForObject(clip) {
      timelineCollectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: animated)
    }
  }

  private func clipForCell(cell: ClipCollectionViewCell) -> Clip? {
    if let indexPath = timelineCollectionView.indexPathForCell(cell) {
      return fetchedResultsController.objectAtIndexPath(indexPath)
    }
    return nil
  }

  private func cellForClip(clip: Clip) -> ClipCollectionViewCell? {
    if let indexPath = fetchedResultsController.indexPathForObject(clip) {
      return timelineCollectionView.cellForItemAtIndexPath(indexPath) as? ClipCollectionViewCell
    }
    return nil
  }

  private func setStateToPlayingClipForVisibleCells(clip: Clip) {
    let playingClipCell = cellForClip(clip)
    for cell in timelineCollectionView.visibleCells() as! [ClipCollectionViewCell] {
      let state: ClipCollectionViewCellState = (cell == playingClipCell) ? .PlayingActive : .PlayingIdle
      cell.setState(state, animated: true)
    }
  }

  private func updateStateForCell(cell: ClipCollectionViewCell) {
    guard let clip = clipForCell(cell) else { return }
    cell.setState(cellStateForClip(clip), animated: true)
  }

  private func updateStateForVisibleCells() {
    for cell in timelineCollectionView.visibleCells() as! [ClipCollectionViewCell] {
      updateStateForCell(cell)
    }
  }

  private func cellStateForClip(clip: Clip) -> ClipCollectionViewCellState {
    var state = ClipCollectionViewCellState.Default
    if clip == timeline.bookmarkedClip {
      state = .Bookmarked
    }
    if player.playing {
      if player.currentClip == clip {
        state = .PlayingActive
      } else {
        state = .PlayingIdle
      }
    }
    return state
  }

  // MARK: Actions

  @objc private func leftBarButtonItemPressed() {
    AppDelegate.sharedInstance.window?.transitionRootViewControllerToViewController(FriendsNavigationController())
  }

  @objc private func rightBarButtonItemPressed() {
    print("NOT IMPLEMENTED: rightBarButtonItemPressed")
  }
}

// MARK: - UICollectionViewDataSource
extension TimelineViewController: UICollectionViewDataSource {

  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return fetchedResultsController.numberOfSections()
  }

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return fetchedResultsController.numberOfRowsForSectionIndex(section)
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(ClipCollectionViewCell), forIndexPath: indexPath) as! ClipCollectionViewCell
    if let clip = fetchedResultsController.objectAtIndexPath(indexPath) {
      cell.configueForClip(clip, state: cellStateForClip(clip))
    }
    cell.delegate = self
    return cell
  }
}

// MARK: - FetchedResultsControllerDelegate
extension TimelineViewController: FetchedResultsControllerDelegate {

  func controllerWillChangeContent<T: Object>(controller: FetchedResultsController<T>) {
    collectionViewUpdates.removeAll()
  }

  func controllerDidChangeSection<T: Object>(controller: FetchedResultsController<T>, section: FetchResultsSectionInfo<T>, sectionIndex: UInt, changeType: NSFetchedResultsChangeType) {
    let section = NSIndexSet(index: Int(sectionIndex))
    collectionViewUpdates.append(NSBlockOperation {
      switch changeType {
      case .Insert:
        self.timelineCollectionView.insertSections(section)
      case .Delete:
        self.timelineCollectionView.deleteSections(section)
      case .Update, .Move:
        self.timelineCollectionView.reloadSections(section)
      }
      }
    )
  }

  func controllerDidChangeObject<T: Object>(controller: FetchedResultsController<T>, anObject object: SafeObject<T>, indexPath: NSIndexPath?, changeType: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
    collectionViewUpdates.append(NSBlockOperation {
      switch changeType {
      case .Insert:
        self.timelineCollectionView.insertItemsAtIndexPaths([newIndexPath!])
      case .Delete:
        self.timelineCollectionView.deleteItemsAtIndexPaths([indexPath!])
      case .Update:
        self.timelineCollectionView.reloadItemsAtIndexPaths([indexPath!])
      case .Move:
        self.timelineCollectionView.moveItemAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
      }
      }
    )
  }

  func controllerDidChangeContent<T: Object>(controller: FetchedResultsController<T>) {
    timelineCollectionView.performBatchUpdates({
      for updateClosure in self.collectionViewUpdates {
        updateClosure.start()
      }
      }, completion: { _ in
        if self.collectionViewUpdates.count > 0 {
          self.updateStateForVisibleCells()
          self.scrollToBookmarkedClip(true)
        }
    })
  }
}

// MARK: - TimelinePlayerDelegate
extension TimelineViewController: TimelinePlayerDelegate {
  func timelinePlayerShouldBeginPlayback(timelinePlayer: TimelinePlayer) -> Bool {
    return true
  }

  func timelinePlayer(timelinePlayer: TimelinePlayer, willBeginPlaybackWithFirstClip clip: Clip) {
    print("will begin")
    navigationController?.setNavigationBarHidden(true, animated: true)
    scrollToCellForClip(clip, animated: true)
    setStateToPlayingClipForVisibleCells(clip)
  }

  func timelinePlayer(timelinePlayer: TimelinePlayer, didBeginPlaybackWithFirstClip clip: Clip) {}

  func timelinePlayer(timelinePlayer: TimelinePlayer, didTransitionFromClip fromClip: Clip, toClip: Clip) {
    print("did transition")
    scrollToCellForClip(toClip, animated: true)
    player.queueManager.ensurePlayerQueueToppedOff()
    updateStateForVisibleCells()
  }

  func timelinePlayer(timelinePlayer: TimelinePlayer, didEndPlaybackWithLastClip clip: Clip) {
    print("did end")
    navigationController?.setNavigationBarHidden(false, animated: true)
    timeline.bookmarkedClip = clip
    updateStateForVisibleCells()
  }
}

// MARK: - ClipCollectionViewCellDelegate
extension TimelineViewController: ClipCollectionViewCellDelegate {
  func clipCollectionViewCellPlayButtonTapped(cell: ClipCollectionViewCell) {
    guard let clip = clipForCell(cell) else { player.stop(); return }
    if player.playing {
      if clip == player.currentClip {
        player.stop()
        return
      } else {
        player.pause()
        player.removeAllItemsExceptCurrentItem()
        player.queueManager.preparePlayerQueueToSkipToClip(clip) {
          self.player.advanceToNextItem()
          self.player.play()
        }
      }
    } else {
      player.queueManager.preparePlayerQueueToPlayClip(clip) {
        self.player.play()
      }
    }
  }
}

// MARK: - UIScrollViewPullToLoadDelegate
extension TimelineViewController: UIScrollViewPullToLoadDelegate {
  func scrollViewDidPullToLoad(scrollView: UIScrollView) {
    timeline.requestNextPageOfClips {
      scrollView.stopPullToLoadAnimation()
    }
  }
}