//
//  TimelineViewController.swift
//  Snowball
//
//  Created by James Martinez on 12/10/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import RealmSwift
import SafeRealmObject
import SwiftFetchedResultsController
import SwiftSpinner
import UIKit

class TimelineViewController: UIViewController {

  // MARK: Properties

  let timeline: Timeline
  let player: TimelinePlayer
  let playerView = PlayerView()
  let playerBufferingImageView = UIImageView()
  let pulsingLoadingIndicatorView = PulsingLoadingIndicatorView()
  let timelineCollectionView = TimelineCollectionView()
  let fetchedResultsController: FetchedResultsController<Clip>
  var collectionViewUpdates = [BlockOperation]()

  /// Used in `HomeTimelineViewController`; after we add a clip,
  /// wait for the fetchedResultsController refresh and *then* scroll to the
  // newly added clip.
  var needsScrollToClip: Clip?

  // MARK: TimelineViewControllerState
  enum TimelineViewControllerState {
    case `default`, recording, playing, previewing
  }
  var state = TimelineViewControllerState.default {
    didSet {
      let navBarHidden = (state == .playing || state == .previewing || state == .recording)
      navigationController?.setNavigationBarHidden(navBarHidden, animated: true)
      playerView.isHidden = (state != .playing)
      timelineCollectionView.isScrollEnabled = (state != .playing && state != .previewing)

      if state != .playing {
        endBufferingState()
      }
    }
  }

  // MARK: Initializers

  init(timelineType: TimelineType) {
    timeline = Timeline(type: timelineType)
    player = TimelinePlayer(timeline: timeline)

    let fetchRequest = FetchRequest<Clip>(realm: Database.realm, predicate: timeline.predicate)
    fetchRequest.sortDescriptors = timeline.sortDescriptors
    fetchedResultsController = FetchedResultsController<Clip>(fetchRequest: fetchRequest, sectionNameKeyPath: nil, cacheName: nil)

    super.init(nibName: nil, bundle: nil)

    let collectionViewLayout = timelineCollectionView.collectionViewLayout as! TimelineCollectionViewFlowLayout
    collectionViewLayout.delegate = self

    NotificationCenter.default.addObserver(self, selector: #selector(TimelineViewController.applicationWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.white

    if navigationController?.viewControllers.first == self {
      navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "top-friends"), style: .plain, target: self, action: #selector(TimelineViewController.leftBarButtonItemPressed))
    } else {
      navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "top-back"), style: .plain, target: self, action: #selector(TimelineViewController.backBarButtonItemPressed))
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
    playerView.isHidden = true

    view.insertSubview(playerBufferingImageView, belowSubview: playerView)
    constrain(playerBufferingImageView, playerView) { playerBufferingImageView, playerView in
      playerBufferingImageView.left == playerView.left
      playerBufferingImageView.top == playerView.top
      playerBufferingImageView.right == playerView.right
      playerBufferingImageView.height == playerView.height
    }

    view.insertSubview(pulsingLoadingIndicatorView, aboveSubview: playerBufferingImageView)
    constrain(pulsingLoadingIndicatorView, playerBufferingImageView) { (pulsingLoadingIndicatorView, playerBufferingImageView) in
      pulsingLoadingIndicatorView.centerX == playerBufferingImageView.centerX
      pulsingLoadingIndicatorView.bottom == playerBufferingImageView.bottom - 15
      pulsingLoadingIndicatorView.width == PulsingLoadingIndicatorView.defaultRadius
      pulsingLoadingIndicatorView.height == PulsingLoadingIndicatorView.defaultRadius
    }

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
    _ = fetchedResultsController.performFetch()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    if isAppearingForFirstTime() {
      refresh()
    }
  }

  // MARK: Internal

  func refresh() {
    timeline.requestRefreshOfClips {
      self.scrollToPriorityClipAnimated(true)
    }
  }

  func clipForCell(_ cell: ClipCollectionViewCell) -> Clip? {
    if let indexPath = timelineCollectionView.indexPath(for: cell) {
      return fetchedResultsController.objectAtIndexPath(indexPath)
    }
    return nil
  }

  func scrollToCellForClip(_ clip: Clip, animated: Bool) {
    if let indexPath = fetchedResultsController.indexPathForObject(clip) {
      timelineCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
    }
  }

  // MARK: Private

  private func cellForClip(_ clip: Clip) -> ClipCollectionViewCell? {
    if let indexPath = fetchedResultsController.indexPathForObject(clip) {
      return timelineCollectionView.cellForItem(at: indexPath) as? ClipCollectionViewCell
    }
    return nil
  }

  private func scrollToPriorityClipAnimated(_ animated: Bool) {
    if let clipNeedingAttenion = self.timeline.clipsNeedingAttention.last {
      self.scrollToCellForClip(clipNeedingAttenion, animated: animated)
    } else if let bookmarkedClip = self.timeline.bookmarkedClip {
      self.scrollToCellForClip(bookmarkedClip, animated: animated)
    }
  }

  fileprivate func setStateToPlayingClipForVisibleCells(_ clip: Clip) {
    let playingClipCell = cellForClip(clip)
    for cell in timelineCollectionView.visibleCells as! [ClipCollectionViewCell] {
      let state: ClipCollectionViewCellState = (cell == playingClipCell) ? .playingActive : .playingIdle
      cell.setState(state, animated: true)
    }
  }

  fileprivate func resetStateForCell(_ cell: ClipCollectionViewCell) {
    guard let clip = clipForCell(cell) else { return }
    cell.setState(cellStateForClip(clip), animated: true)
  }

  fileprivate func resetStateForVisibleCells() {
    for cell in timelineCollectionView.visibleCells as! [ClipCollectionViewCell] {
      resetStateForCell(cell)
    }
  }

  fileprivate func reconfigureVisibleCells() {
    for cell in timelineCollectionView.visibleCells as! [ClipCollectionViewCell] {
      guard let clip = clipForCell(cell) else { return }
      cell.configueForClip(clip, state: cellStateForClip(clip), animated: true)
    }
  }

  fileprivate func cellStateForClip(_ clip: Clip) -> ClipCollectionViewCellState {
    var state = ClipCollectionViewCellState.default
    if player.playing {
      if player.currentClip == clip {
        state = .playingActive
      } else {
        state = .playingIdle
      }
    } else {
      if clip == timeline.bookmarkedClip {
        state = .bookmarked
      }
      if clip.state == .PendingAcceptance {
        state = .pendingAcceptance
      } else if clip.state == .UploadFailed {
        state = .uploadFailed
      } else if clip.state == .Uploading {
        state = .uploading
      }
    }
    return state
  }

  fileprivate func setClipBuffering(_ clip: Clip) {
    if let thumbnailURLString = clip.thumbnailURL, let thumbnailURL = URL(string: thumbnailURLString) {
      playerBufferingImageView.setImageFromURL(thumbnailURL)
      pulsingLoadingIndicatorView.startAnimating()
    }
  }

  private func endBufferingState() {
    playerBufferingImageView.image = nil
    pulsingLoadingIndicatorView.stopAnimating()
  }

  // MARK: Actions

  @objc private func applicationWillEnterForeground() {
    refresh()
  }

  @objc private func backBarButtonItemPressed() {
    navigationController?.popViewController(animated: true)
  }

  @objc private func leftBarButtonItemPressed() {
    authenticateUser(
      afterSuccessfulAuthentication:  {
        self.refresh()
      },
      whenAlreadyAuthenticated: {
        AppDelegate.sharedInstance.window?.transitionRootViewControllerToViewController(FriendsNavigationController())
    })
  }
}

// MARK: - UICollectionViewDataSource
extension TimelineViewController: UICollectionViewDataSource {

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return fetchedResultsController.numberOfSections()
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return fetchedResultsController.numberOfRowsForSectionIndex(section)
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(ClipCollectionViewCell.self), for: indexPath) as! ClipCollectionViewCell
    if let clip = fetchedResultsController.objectAtIndexPath(indexPath) {
      cell.configueForClip(clip, state: cellStateForClip(clip))
    }
    cell.delegate = self
    return cell
  }
}

// MARK: - FetchedResultsControllerDelegate
extension TimelineViewController: FetchedResultsControllerDelegate {

  func controllerWillChangeContent<T>(_ controller: FetchedResultsController<T>) {
    collectionViewUpdates.removeAll()
  }

  func controllerDidChangeSection<T>(_ controller: FetchedResultsController<T>, section: FetchResultsSectionInfo<T>, sectionIndex: UInt, changeType: NSFetchedResultsChangeType) {
    let section = IndexSet(integer: Int(sectionIndex))
    collectionViewUpdates.append(BlockOperation {
      switch changeType {
      case .insert:
        self.timelineCollectionView.insertSections(section)
      case .delete:
        self.timelineCollectionView.deleteSections(section)
      case .update, .move:
        self.timelineCollectionView.reloadSections(section)
      }
      }
    )
  }

  func controller<T>(_ controller: FetchedResultsController<T>, didChangeObject object: SafeObject<T>, atIndexPath indexPath: IndexPath?, forChangeType changeType: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    collectionViewUpdates.append(BlockOperation {
      switch changeType {
      case .insert:
        self.timelineCollectionView.insertItems(at: [newIndexPath!])
      case .delete:
        self.timelineCollectionView.deleteItems(at: [indexPath!])
      case .update:
        let clip = self.timeline.clips[indexPath!.row]
        if let cell = self.timelineCollectionView.cellForItem(at: indexPath!) as? ClipCollectionViewCell {
          let state = self.cellStateForClip(clip)
          cell.setState(state, animated: true)
        }
      case .move:
        self.timelineCollectionView.moveItem(at: indexPath!, to: newIndexPath!)
      }
      }
    )
  }

  func controllerDidChangeContent<T>(_ controller: FetchedResultsController<T>) {
    timelineCollectionView.performBatchUpdates({
      for updateClosure in self.collectionViewUpdates {
        updateClosure.start()
      }
      }, completion: { _ in
        if self.collectionViewUpdates.count > 0 {
          if let clip = self.needsScrollToClip {
            self.needsScrollToClip = nil
            self.scrollToCellForClip(clip, animated: true)
          }
          self.reconfigureVisibleCells()
        }
    })
  }
}

// MARK: - TimelinePlayerDelegate
extension TimelineViewController: TimelinePlayerDelegate {
  func timelinePlayerShouldBeginPlayback(_ timelinePlayer: TimelinePlayer) -> Bool {
    return true
  }

  func timelinePlayer(_ timelinePlayer: TimelinePlayer, willBeginPlaybackWithFirstClip clip: Clip) {
    state = .playing
    setClipBuffering(clip)
    scrollToCellForClip(clip, animated: true)
    setStateToPlayingClipForVisibleCells(clip)
    Analytics.track("Watch Clip")
  }

  func timelinePlayer(_ timelinePlayer: TimelinePlayer, didTransitionFromClip fromClip: Clip, toClip: Clip) {
    setClipBuffering(toClip)
    scrollToCellForClip(toClip, animated: true)
    player.topOffQueue()
    resetStateForVisibleCells()
    Analytics.track("Watch Clip")
  }

  func timelinePlayer(_ timelinePlayer: TimelinePlayer, didEndPlaybackWithLastClip clip: Clip) {
    state = .default
    timeline.bookmarkedClip = clip
    resetStateForVisibleCells()
  }
}

// MARK: - ClipCollectionViewCellDelegate
extension TimelineViewController: ClipCollectionViewCellDelegate {
  func clipCollectionViewCellPlayButtonTapped(_ cell: ClipCollectionViewCell) {
    guard let clip = clipForCell(cell) else { player.stop(); return }
    if player.playing {
      if clip == player.currentClip {
        player.stop()
        return
      } else {
        player.skipToClip(clip)
      }
    } else {
      player.playWithFirstClip(clip)
    }
  }

  func clipCollectionViewCellAddButtonTapped(_ cell: ClipCollectionViewCell) {}

  func clipCollectionViewCellRetryUploadButtonTapped(_ cell: ClipCollectionViewCell) {}

  func clipCollectionViewCellProfileButtonTapped(_ cell: ClipCollectionViewCell) {
    authenticateUser(
      afterSuccessfulAuthentication:  {
        self.refresh()
      },
      whenAlreadyAuthenticated: {
        guard let clip = self.clipForCell(cell), let user = clip.user else { return }
        self.navigationController?.pushViewController(UserTimelineViewController(user: user), animated: true)
    })
  }

  func clipCollectionViewCellLongPressTriggered(_ cell: ClipCollectionViewCell) {
    cell.setState(.options, animated: true)
    guard let clip = clipForCell(cell), let user = clip.user else { return }
    authenticateUser(
      afterSuccessfulAuthentication: {
        self.refresh()
      },
      whenAlreadyAuthenticated: {
        let isCurrentUser = (user == User.currentUser)

        let confirmed: (UIAlertAction) -> Void = { action in
          if isCurrentUser {
            guard let clipID = clip.id else {
              // Clip does not have an ID but user wants to delete it
              if user == User.currentUser {
                Database.performTransaction {
                  Database.delete(clip)
                }
              }
              return
            }
            SwiftSpinner.show(NSLocalizedString("Deleting...", comment: ""))
            SnowballAPI.request(SnowballRoute.deleteClip(clipID: clipID)) { response in
              SwiftSpinner.hide()
              switch response {
              case .success:
                Database.performTransaction {
                  Database.delete(clip)
                }
              case .failure(let error):
                print(error) // TODO: Handle error
              }
            }
          } else {
            guard let clipID = clip.id else { return }
            SwiftSpinner.show(NSLocalizedString("Flagging...", comment: ""))
            SnowballAPI.request(SnowballRoute.flagClip(clipID: clipID)) { response in
              SwiftSpinner.hide()
              switch response {
              case .success:
                self.resetStateForCell(cell)
              case .failure(let error):
                print(error) // TODO: Handle error
              }
            }
          }
        }
        let cancelled: (UIAlertAction) -> Void = { action in
          self.resetStateForCell(cell)
        }

        var alertConfirmAction: UIAlertAction
        var alertCancelAction: UIAlertAction
        if isCurrentUser {
          alertConfirmAction = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive, handler: confirmed)
          alertCancelAction = UIAlertAction(title: NSLocalizedString("Don't Delete", comment: ""), style: .cancel, handler: cancelled)
        } else {
          alertConfirmAction = UIAlertAction(title: NSLocalizedString("Flag", comment: ""), style: .destructive, handler: confirmed)
          alertCancelAction = UIAlertAction(title: NSLocalizedString("Don't Flag", comment: ""), style: .cancel, handler: cancelled)
        }

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(alertConfirmAction)
        alert.addAction(alertCancelAction)
        self.present(alert, animated: true, completion: nil)
    })
  }

  func clipCollectionViewCellLikeButtonTapped(_ cell: ClipCollectionViewCell) {
    guard let clip = clipForCell(cell), let clipID = clip.id else { return }
    authenticateUser(
      afterSuccessfulAuthentication: {
        self.refresh()
    },
      whenAlreadyAuthenticated: {
        let likedCurrently = clip.liked
        func setClipLiked(_ liked: Bool) {
          Database.performTransaction {
            clip.liked = liked
            Database.save(clip)
          }
        }
        setClipLiked(!likedCurrently)
        let route: SnowballRoute
        if likedCurrently {
          route = SnowballRoute.unlikeClip(clipID: clipID)
          Analytics.track("Unlike Clip")
        } else {
          route = SnowballRoute.likeClip(clipID: clipID)
          Analytics.track("Like Clip")
        }
        SnowballAPI.request(route) { response in
          switch response {
          case .success: break
          case .failure(let error):
            print(error)
            setClipLiked(likedCurrently)
          }
        }
    })
  }
}

// MARK: - UIScrollViewPullToLoadDelegate
extension TimelineViewController: UIScrollViewPullToLoadDelegate {
  func scrollViewDidPullToLoad(_ scrollView: UIScrollView) {
    timeline.requestNextPageOfClips {
      scrollView.stopPullToLoadAnimation()
    }
  }
}

// MARK: - TimelineCollectionViewDelegate
extension TimelineViewController: TimelineCollectionViewDelegate {
  func timelineCollectionViewSwipedLeft(_ collectionView: TimelineCollectionView) {
    if let currentClip = player.currentClip, let nextClip = timeline.clipAfterClip(currentClip) {
      player.skipToClip(nextClip)
    }
  }

  func timelineCollectionViewSwipedRight(_ collectionView: TimelineCollectionView) {
    if let currentClip = player.currentClip, let previousClip = timeline.clipBeforeClip(currentClip) {
      player.skipToClip(previousClip)
    }
  }
}

// MARK: - TimelineCollectionViewFlowLayoutDelegate
extension TimelineViewController: TimelineCollectionViewFlowLayoutDelegate {
  func timelineCollectionViewFlowLayout(_ layout: TimelineCollectionViewFlowLayout, willFinalizeCollectionViewUpdates updates: [UICollectionViewUpdateItem]) {

    // Only reloads of cells, no insert/delete here
    // There are no updates here since we're not calling "reloadItemAtIndexPath" when the FRC updates
    if updates.count == 0 { return }

    // If we're inserting a clip that is pending acceptance OR
    // if we're performing any other action besides an insert on a single clip
    // e.g. adding a clip, deleting a clip, etc.
    // we let the default scroll handler do it, or use other scroll overrides
    if updates.count == 1, let update = updates.first {
      if update.updateAction == .insert {
        let clip = timeline.clips[update.indexPathAfterUpdate!.row]
        if clip.state == .PendingAcceptance {
          return
        }
      } else {
        return
      }
    }

    if timeline.currentPage > 1 {
      // Loading another page
      let contentSizeBeforeAnimation = timelineCollectionView.contentSize
      let contentSizeAfterAnimation = layout.collectionViewContentSize
      let xOffset = contentSizeAfterAnimation.width - contentSizeBeforeAnimation.width
      if xOffset < 0 {
        timelineCollectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
      } else {
        timelineCollectionView.setContentOffset(CGPoint(x: xOffset, y: 0), animated: false)
      }
    }
  }
}
