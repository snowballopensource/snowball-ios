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
import SwiftSpinner
import UIKit

class TimelineViewController: UIViewController {

  // MARK: Properties

  let timeline: Timeline
  let cameraViewController: CameraViewController?
  let player: TimelinePlayer
  let playerView = PlayerView()
  let timelineCollectionView = TimelineCollectionView()
  let fetchedResultsController: FetchedResultsController<Clip>
  var collectionViewUpdates = [NSBlockOperation]()

  // MARK: TimelineViewControllerState
  private enum TimelineViewControllerState {
    case Default, Recording, Playing
  }
  private var state = TimelineViewControllerState.Default {
    didSet {
      let navBarHidden = (state == .Playing || state == .Recording)
      navigationController?.setNavigationBarHidden(navBarHidden, animated: true)
      playerView.hidden = (state != .Playing)
      timelineCollectionView.scrollEnabled = (state != .Playing)
    }
  }

  // MARK: Initializers

  init(timelineType: TimelineType) {
    timeline = Timeline(type: timelineType)
    player = TimelinePlayer(timeline: timeline)

    if timelineType == .Home {
      cameraViewController = CameraViewController()
    } else {
      cameraViewController = nil
    }

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

    view.backgroundColor = UIColor.whiteColor()

    if navigationController?.viewControllers.first == self {
      navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "top-friends"), style: .Plain, target: self, action: "leftBarButtonItemPressed")
    } else {
      navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "top-back"), style: .Plain, target: self, action: "backBarButtonItemPressed")
    }

    if let cameraViewController = cameraViewController {
      navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "top-flip-camera"), style: .Plain, target: self, action: "rightBarButtonItemPressed")

      addChildViewController(cameraViewController)
      view.addSubview(cameraViewController.view)
      constrain(cameraViewController.view) { cameraView in
        cameraView.left == cameraView.superview!.left
        cameraView.top == cameraView.superview!.top
        cameraView.right == cameraView.superview!.right
        cameraView.height == cameraView.superview!.width
      }
      cameraViewController.didMoveToParentViewController(self)
      cameraViewController.delegate = self
    }

    view.addSubview(playerView)
    constrain(playerView) { playerView in
      playerView.left == playerView.superview!.left
      playerView.top == playerView.superview!.top
      playerView.right == playerView.superview!.right
      playerView.height == playerView.superview!.width
    }
    player.delegate = self
    playerView.player = player
    playerView.hidden = true

    view.addSubview(timelineCollectionView)
    constrain(timelineCollectionView, playerView) { timelineCollectionView, playerView in
      timelineCollectionView.left == timelineCollectionView.superview!.left
      timelineCollectionView.top == playerView.bottom
      timelineCollectionView.right == timelineCollectionView.superview!.right
      timelineCollectionView.bottom == timelineCollectionView.superview!.bottom
    }
    timelineCollectionView.dataSource = self
    timelineCollectionView.timelineDelegate = self
    timelineCollectionView.enablePullToLoadWithDelegate(self)

    fetchedResultsController.delegate = self
    fetchedResultsController.performFetch()
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    if isAppearingForFirstTime() {
      timeline.requestRefreshOfClips()
    }
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    if isAppearingForFirstTime() {
      scrollToRelevantClip(animated)
    }
  }

  // MARK: - Private

  private func scrollToRelevantClip(animated: Bool) {
    if let clipNeedingAttention = timeline.clipsNeedingAttention.last {
      scrollToCellForClip(clipNeedingAttention, animated: animated)
    } else if let bookmarkedClip = timeline.bookmarkedClip {
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

  private func resetStateForCell(cell: ClipCollectionViewCell) {
    guard let clip = clipForCell(cell) else { return }
    cell.setState(cellStateForClip(clip), animated: true)
  }

  private func resetStateForVisibleCells() {
    for cell in timelineCollectionView.visibleCells() as! [ClipCollectionViewCell] {
      resetStateForCell(cell)
    }
  }

  private func cellStateForClip(clip: Clip) -> ClipCollectionViewCellState {
    var state = ClipCollectionViewCellState.Default
    if player.playing {
      if player.currentClip == clip {
        state = .PlayingActive
      } else {
        state = .PlayingIdle
      }
    } else {
      if clip == timeline.bookmarkedClip {
        state = .Bookmarked
      }
      if clip.state == .PendingAcceptance {
        state = .PendingAcceptance
      } else if clip.state == .UploadFailed {
        state = .UploadFailed
      }
    }
    return state
  }

  private func skipToClip(clip: Clip) {
    player.pause()
    player.removeAllItemsExceptCurrentItem()
    player.queueManager.preparePlayerQueueToSkipToClip(clip) {
      self.player.advanceToNextItem()
      self.player.play()
    }
  }

  // MARK: Actions

  @objc private func backBarButtonItemPressed() {
    navigationController?.popViewControllerAnimated(true)
  }

  @objc private func leftBarButtonItemPressed() {
    AppDelegate.sharedInstance.window?.transitionRootViewControllerToViewController(FriendsNavigationController())
  }

  @objc private func rightBarButtonItemPressed() {
    cameraViewController?.changeCamera()
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
          self.resetStateForVisibleCells()
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
    state = .Playing
    scrollToCellForClip(clip, animated: true)
    setStateToPlayingClipForVisibleCells(clip)
  }

  func timelinePlayer(timelinePlayer: TimelinePlayer, didBeginPlaybackWithFirstClip clip: Clip) {}

  func timelinePlayer(timelinePlayer: TimelinePlayer, didTransitionFromClip fromClip: Clip, toClip: Clip) {
    print("did transition")
    scrollToCellForClip(toClip, animated: true)
    player.queueManager.ensurePlayerQueueToppedOff()
    resetStateForVisibleCells()
  }

  func timelinePlayer(timelinePlayer: TimelinePlayer, didEndPlaybackWithLastClip clip: Clip) {
    print("did end")
    state = .Default
    timeline.bookmarkedClip = clip
    resetStateForVisibleCells()
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
        skipToClip(clip)
      }
    } else {
      player.queueManager.preparePlayerQueueToPlayClip(clip) {
        self.player.play()
      }
    }
  }

  func clipCollectionViewCellAddButtonTapped(cell: ClipCollectionViewCell) {
    guard let clip = clipForCell(cell) else { return }
    cameraViewController?.endPreview()
    tryUploadingClip(clip)
  }

  func clipCollectionViewCellRetryUploadButtonTapped(cell: ClipCollectionViewCell) {
    guard let clip = clipForCell(cell) else { return }
    tryUploadingClip(clip)
  }

  func clipCollectionViewCellProfileButtonTapped(cell: ClipCollectionViewCell) {
    guard let clip = clipForCell(cell), let userID = clip.user?.id else { return }
    navigationController?.pushViewController(TimelineViewController(timelineType: .User(userID: userID)), animated: true)
  }

  func clipCollectionViewCellLongPressTriggered(cell: ClipCollectionViewCell) {
    cell.setState(.Options, animated: true)
  }

  func clipcollectionViewCellOptionsButtonTapped(cell: ClipCollectionViewCell) {
    guard let clip = clipForCell(cell), let clipID = clip.id, let user = clip.user else { return }

    let isCurrentUser = (user == User.currentUser)

    let confirmed: UIAlertAction -> Void = { action in
      let completion: Response -> Void = { response in
        SwiftSpinner.hide()
        switch response {
        case .Success:
          self.resetStateForCell(cell)
        case .Failure(let error):
          print(error) // TODO: Handle error
        }
      }
      if isCurrentUser {
        SwiftSpinner.show(NSLocalizedString("Deleting...", comment: ""))
        SnowballAPI.request(SnowballRoute.DeleteClip(clipID: clipID), completion: completion)
      } else {
        SwiftSpinner.show(NSLocalizedString("Flagging...", comment: ""))
        SnowballAPI.request(SnowballRoute.FlagClip(clipID: clipID), completion: completion)
      }
    }
    let cancelled: UIAlertAction -> Void = { action in
      self.resetStateForCell(cell)
    }

    var alertTitle: String
    var alertMessage: String
    var alertConfirmAction: UIAlertAction
    var alertCancelAction: UIAlertAction
    if isCurrentUser {
      alertTitle = NSLocalizedString("Delete this clip?", comment: "")
      alertMessage = NSLocalizedString("Are you sure you want to delete this clip?", comment: "")
      alertConfirmAction = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .Destructive, handler: confirmed)
      alertCancelAction = UIAlertAction(title: NSLocalizedString("Don't Delete", comment: ""), style: .Cancel, handler: cancelled)
    } else {
      alertTitle = NSLocalizedString("Flag this clip?", comment: "")
      alertMessage = NSLocalizedString("Are you sure you want to flag this clip?", comment: "")
      alertConfirmAction = UIAlertAction(title: NSLocalizedString("Flag", comment: ""), style: .Destructive, handler: confirmed)
      alertCancelAction = UIAlertAction(title: NSLocalizedString("Don't Flag", comment: ""), style: .Cancel, handler: cancelled)
    }

    let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .ActionSheet)
    alert.addAction(alertConfirmAction)
    alert.addAction(alertCancelAction)
    presentViewController(alert, animated: true, completion: nil)
  }

  // MARK: Private

  private func tryUploadingClip(clip: Clip) {
    state = .Default
    SnowballAPI.queueClipForUploadingAndHandleStateChanges(clip) { (response) -> Void in
      switch response {
      case .Success: break
      case .Failure(let error): print(error) // TODO: Handle error
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

// MARK: - CameraViewControllerDelegate
extension TimelineViewController: CameraViewControllerDelegate {
  func videoDidBeginRecording() {
    state = .Recording
  }

  func videoDidEndRecordingToFileAtURL(videoURL: NSURL, thumbnailURL: NSURL) {
    let clip = Clip()
    clip.state = .PendingAcceptance
    clip.timelineID = timeline.id
    clip.inHomeTimeline = true
    clip.videoURL = videoURL.absoluteString
    clip.thumbnailURL = thumbnailURL.absoluteString
    clip.user = User.currentUser
    Database.performTransaction {
      Database.save(clip)
    }
    scrollToCellForClip(clip, animated: true)
  }

  func videoPreviewDidCancel() {
    state = .Default
    if let pendingClip = timeline.clipPendingAcceptance {
      Database.performTransaction {
        Database.delete(pendingClip)
      }
    }
  }
}

// MARK: - TimelineCollectionViewDelegate
extension TimelineViewController: TimelineCollectionViewDelegate {
  func timelineCollectionViewSwipedLeft(collectionView: TimelineCollectionView) {
    if let currentClip = player.currentClip, nextClip = timeline.clipAfterClip(currentClip) {
      skipToClip(nextClip)
    }
  }

  func timelineCollectionViewSwipedRight(collectionView: TimelineCollectionView) {
    if let currentClip = player.currentClip, previousClip = timeline.clipBeforeClip(currentClip) {
      skipToClip(previousClip)
    }
  }
}