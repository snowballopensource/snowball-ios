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
  let player: TimelinePlayer
  let playerView = PlayerView()
  let playerBufferingImageView = UIImageView()
  let pulsingLoadingIndicatorView = PulsingLoadingIndicatorView()
  let timelineCollectionView = TimelineCollectionView()
  let fetchedResultsController: FetchedResultsController<Clip>
  var collectionViewUpdates = [NSBlockOperation]()
  var shouldOverrideScrollPosition = true

  // MARK: TimelineViewControllerState
  enum TimelineViewControllerState {
    case Default, Recording, Playing
  }
  var state = TimelineViewControllerState.Default {
    didSet {
      let navBarHidden = (state == .Playing || state == .Recording)
      navigationController?.setNavigationBarHidden(navBarHidden, animated: true)
      playerView.hidden = (state != .Playing)
      timelineCollectionView.scrollEnabled = (state != .Playing)

      if state != .Playing {
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

    NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillEnterForeground", name: UIApplicationWillEnterForegroundNotification, object: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
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
    fetchedResultsController.performFetch()
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    if isAppearingForFirstTime() {
      refresh()
    }
  }

  // MARK: Internal

  func refresh() {
    timeline.requestRefreshOfClips()
  }

  func clipForCell(cell: ClipCollectionViewCell) -> Clip? {
    if let indexPath = timelineCollectionView.indexPathForCell(cell) {
      return fetchedResultsController.objectAtIndexPath(indexPath)
    }
    return nil
  }

  func performWithoutScrollOverride(closure: () -> Void) {
    shouldOverrideScrollPosition = false
    closure()
    shouldOverrideScrollPosition = true
  }

  // MARK: Private

  private func cellForClip(clip: Clip) -> ClipCollectionViewCell? {
    if let indexPath = fetchedResultsController.indexPathForObject(clip) {
      return timelineCollectionView.cellForItemAtIndexPath(indexPath) as? ClipCollectionViewCell
    }
    return nil
  }

  private func scrollToCellForClip(clip: Clip, animated: Bool) {
    if let indexPath = fetchedResultsController.indexPathForObject(clip) {
      timelineCollectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: animated)
    }
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
      } else if clip.state == .Uploading {
        state = .Uploading
      }
    }
    return state
  }

  private func setClipBuffering(clip: Clip) {
    if let thumbnailURLString = clip.thumbnailURL, thumbnailURL = NSURL(string: thumbnailURLString) {
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
    navigationController?.popViewControllerAnimated(true)
  }

  @objc private func leftBarButtonItemPressed() {
    AppDelegate.sharedInstance.window?.transitionRootViewControllerToViewController(FriendsNavigationController())
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
        let clip = self.timeline.clips[indexPath!.row]
        if let cell = self.timelineCollectionView.cellForItemAtIndexPath(indexPath!) as? ClipCollectionViewCell {
          let state = self.cellStateForClip(clip)
          cell.setState(state, animated: true)
        }
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
    state = .Playing
    setClipBuffering(clip)
    scrollToCellForClip(clip, animated: true)
    setStateToPlayingClipForVisibleCells(clip)
  }

  func timelinePlayer(timelinePlayer: TimelinePlayer, didBeginPlaybackWithFirstClip clip: Clip) {}

  func timelinePlayer(timelinePlayer: TimelinePlayer, didTransitionFromClip fromClip: Clip, toClip: Clip) {
    setClipBuffering(toClip)
    scrollToCellForClip(toClip, animated: true)
    player.topOffQueue()
    resetStateForVisibleCells()
  }

  func timelinePlayer(timelinePlayer: TimelinePlayer, didEndPlaybackWithLastClip clip: Clip) {
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
        player.skipToClip(clip)
      }
    } else {
      player.playWithFirstClip(clip)
    }
  }

  func clipCollectionViewCellAddButtonTapped(cell: ClipCollectionViewCell) {}

  func clipCollectionViewCellRetryUploadButtonTapped(cell: ClipCollectionViewCell) {}

  func clipCollectionViewCellProfileButtonTapped(cell: ClipCollectionViewCell) {
    guard let clip = clipForCell(cell), let user = clip.user else { return }
    navigationController?.pushViewController(UserTimelineViewController(user: user), animated: true)
  }

  func clipCollectionViewCellLongPressTriggered(cell: ClipCollectionViewCell) {
    cell.setState(.Options, animated: true)
  }

  func clipCollectionViewCellOptionsButtonTapped(cell: ClipCollectionViewCell) {
    guard let clip = clipForCell(cell), let user = clip.user else { return }
    guard let clipID = clip.id else {
      // Clip does not have an ID but user wants to delete it
      if user == User.currentUser {
        Database.performTransaction {
          Database.delete(clip)
        }
      }
      return
    }
    authenticateUser(
      afterSuccessfulAuthentication: {
        self.refresh()
      },
      whenAlreadyAuthenticated: {
        let isCurrentUser = (user == User.currentUser)

        let confirmed: UIAlertAction -> Void = { action in
          if isCurrentUser {
            SwiftSpinner.show(NSLocalizedString("Deleting...", comment: ""))
            SnowballAPI.request(SnowballRoute.DeleteClip(clipID: clipID)) { response in
              SwiftSpinner.hide()
              switch response {
              case .Success:
                Database.performTransaction {
                  Database.delete(clip)
                }
              case .Failure(let error):
                print(error) // TODO: Handle error
              }
            }
          } else {
            SwiftSpinner.show(NSLocalizedString("Flagging...", comment: ""))
            SnowballAPI.request(SnowballRoute.FlagClip(clipID: clipID)) { response in
              SwiftSpinner.hide()
              switch response {
              case .Success:
                self.resetStateForCell(cell)
              case .Failure(let error):
                print(error) // TODO: Handle error
              }
            }
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
        self.presentViewController(alert, animated: true, completion: nil)
    })
  }

  func clipCollectionViewCellLikeButtonTapped(cell: ClipCollectionViewCell) {
    guard let clip = clipForCell(cell), clipID = clip.id else { return }
    authenticateUser(
      afterSuccessfulAuthentication: {
        self.refresh()
    },
      whenAlreadyAuthenticated: {
        let likedCurrently = clip.liked
        func setClipLiked(liked: Bool) {
          Database.performTransaction {
            clip.liked = liked
            Database.save(clip)
          }
        }
        setClipLiked(!likedCurrently)
        let route: SnowballRoute
        if likedCurrently {
          route = SnowballRoute.UnlikeClip(clipID: clipID)
        } else {
          route = SnowballRoute.LikeClip(clipID: clipID)
        }
        SnowballAPI.request(route) { response in
          switch response {
          case .Success: break
          case .Failure(let error):
            print(error)
            setClipLiked(likedCurrently)
          }
        }
    })
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

// MARK: - TimelineCollectionViewDelegate
extension TimelineViewController: TimelineCollectionViewDelegate {
  func timelineCollectionViewSwipedLeft(collectionView: TimelineCollectionView) {
    if let currentClip = player.currentClip, nextClip = timeline.clipAfterClip(currentClip) {
      player.skipToClip(nextClip)
    }
  }

  func timelineCollectionViewSwipedRight(collectionView: TimelineCollectionView) {
    if let currentClip = player.currentClip, previousClip = timeline.clipBeforeClip(currentClip) {
      player.skipToClip(previousClip)
    }
  }
}

// MARK: - TimelineCollectionViewFlowLayoutDelegate
extension TimelineViewController: TimelineCollectionViewFlowLayoutDelegate {
  func timelineCollectionViewFlowLayoutWillFinalizeCollectionViewUpdates(layout: TimelineCollectionViewFlowLayout) {
    if shouldOverrideScrollPosition {
      if let clipNeedingAttention = timeline.clipsNeedingAttention.last {
        scrollToCellForClip(clipNeedingAttention, animated: false)
      } else {
        if timeline.currentPage == 1 {
          if let bookmarkedClip = timeline.bookmarkedClip {
            scrollToCellForClip(bookmarkedClip, animated: false)
          }
        } else {
          // Calculate offset...
          let contentSizeBeforeAnimation = timelineCollectionView.contentSize
          let contentSizeAfterAnimation = layout.collectionViewContentSize()
          let xOffset = contentSizeAfterAnimation.width - contentSizeBeforeAnimation.width
          if xOffset < 0 {
            timelineCollectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
          } else {
            timelineCollectionView.setContentOffset(CGPoint(x: xOffset, y: 0), animated: false)
          }
        }
      }
    }
  }
}