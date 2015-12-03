//
//  MainTimelineViewController.swift
//  Snowball
//
//  Created by James Martinez on 7/28/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class MainTimelineViewController: TimelineViewController {

  // MARK: - Properties

  private let cameraViewController = CameraViewController()

  private let onboardingAnnotationPlay: UIImageView = {
    let imageView = UIImageView(image: UIImage(named: "coachmark-play"))
    imageView.userInteractionEnabled = false
    return imageView
  }()
  private let onboardingAnnotationCapture: UIImageView = {
    let imageView = UIImageView(image: UIImage(named: "coachmark-capture"))
    imageView.userInteractionEnabled = false
    return imageView
  }()
  private let onboardingAnnotationAdd: UIImageView = {
    let imageView = UIImageView(image: UIImage(named: "coachmark-add"))
    imageView.userInteractionEnabled = false
    return imageView
  }()

  private let kCaptureOnboardingCompletedKey = "CaptureOnboardingCompleted"
  private var onboardingCompleted: Bool {
    get {
      if User.currentUser != nil {
        self.onboardingCompleted = true
      }
      return NSUserDefaults.standardUserDefaults().boolForKey(kCaptureOnboardingCompletedKey)
    }
    set {
      NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: kCaptureOnboardingCompletedKey)
      NSUserDefaults.standardUserDefaults().synchronize()
    }
  }

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    cameraViewController.delegate = self

    timeline.loadCachedClips()

    setOnboardingAnnotationPlayHidden(onboardingCompleted, animated: false)
    setOnboardingAnnotationCaptureHidden(true, animated: false)
    setOnboardingAnnotationAddHidden(true, animated: false)
  }

  override func loadView() {
    super.loadView()

    addChildViewController(cameraViewController)
    view.addSubview(cameraViewController.view)
    cameraViewController.didMoveToParentViewController(self)
    constrain(cameraViewController.view) { (cameraView) in
      cameraView.left == cameraView.superview!.left
      cameraView.top == cameraView.superview!.top
      cameraView.right == cameraView.superview!.right
      cameraView.height == cameraView.width
    }

    topView = SnowballTopView(leftButtonType: SnowballTopViewButtonType.Friends, rightButtonType: SnowballTopViewButtonType.ChangeCamera)
    view.addSubview(topView)
    topView.setupDefaultLayout()

    view.addSubview(onboardingAnnotationPlay)
    constrain(onboardingAnnotationPlay, cameraViewController.view) { onboardingAnnotationPlay, cameraView in
      onboardingAnnotationPlay.left == cameraView.left + 15
      onboardingAnnotationPlay.bottom == cameraView.bottom + 30
      onboardingAnnotationPlay.width == self.onboardingAnnotationPlay.image!.size.width
      onboardingAnnotationPlay.height == self.onboardingAnnotationPlay.image!.size.height
    }

    view.addSubview(onboardingAnnotationCapture)
    constrain(onboardingAnnotationCapture, cameraViewController.view) { onboardingAnnotationCapture, cameraView in
      onboardingAnnotationCapture.center == cameraView.center
      onboardingAnnotationCapture.width == self.onboardingAnnotationCapture.image!.size.width
      onboardingAnnotationCapture.height == self.onboardingAnnotationCapture.image!.size.height
    }

    view.addSubview(onboardingAnnotationAdd)
    constrain(onboardingAnnotationAdd, cameraViewController.view) { onboardingAnnotationAdd, cameraView in
      onboardingAnnotationAdd.right == cameraView.right - 15
      onboardingAnnotationAdd.bottom == cameraView.bottom + 15
      onboardingAnnotationAdd.width == self.onboardingAnnotationAdd.image!.size.width
      onboardingAnnotationAdd.height == self.onboardingAnnotationAdd.image!.size.height
    }
  }

  // MARK: - TimelineViewController

  override func loadPage(page: Int) {
    timeline.requestHomeTimeline(page: page) { (error) -> Void in
      error?.alertUser()
    }
  }

  override func stateForCellAtIndexPath(indexPath: NSIndexPath) -> ClipCollectionViewCellState {
    let superState = super.stateForCellAtIndexPath(indexPath)
    if superState != ClipCollectionViewCellState.Default {
      return superState
    }
    let clip = timeline.clips[indexPath.row]
    if let bookmarkedClip = timeline.bookmarkedClip {
      if clip == bookmarkedClip {
        return ClipCollectionViewCellState.Bookmarked
      }
    }
    return superState
  }

  // MARK: - TimelineDelegate
  // See the comment in TimelineViewController for the TimelinePlayer delegate
  // to see why this is here. It's such a confusing mess. Sorry future self!
  override func timelineClipsDidLoadFromCache() {
    super.timelineClipsDidLoadFromCache()

    collectionView.layoutIfNeeded() // Hack to ensure that the scrolling will take place

    scrollToPendingOrBookmark(false)
  }

  // MARK: - TimelinePlayerDelegate
  // See the comment in TimelineViewController for the TimelinePlayer delegate
  // to see why this is here. It's such a confusing mess. Sorry future self!
  override func timelinePlayer(timelinePlayer: TimelinePlayer, shouldBeginPlayingWithClip clip: Clip) -> Bool {
    super.timelinePlayer(timelinePlayer, shouldBeginPlayingWithClip: clip)
    return cameraViewController.state == CameraViewControllerState.Default
  }

  override func timelinePlayer(timelinePlayer: TimelinePlayer, didBeginPlayingWithClip clip: Clip) {
    super.timelinePlayer(timelinePlayer, didBeginPlayingWithClip: clip)
    setOnboardingAnnotationPlayHidden(true, animated: true)
    view.sendSubviewToBack(cameraViewController.view)
  }

  override func timelinePlayer(timelinePlayer: TimelinePlayer, didEndPlayingWithLastClip lastClip: Clip) {
    super.timelinePlayer(timelinePlayer, didEndPlayingWithLastClip: lastClip)
    setOnboardingAnnotationCaptureHidden(onboardingCompleted, animated: true)
    view.sendSubviewToBack(playerView)
  }

  // MARK: - TimelineFlowLayoutDelegate
  override func timelineFlowLayoutDidFinalizeCollectionViewUpdates(layout: TimelineFlowLayout) {
    super.timelineFlowLayoutDidFinalizeCollectionViewUpdates(layout)

    scrollToPendingOrBookmark(false)
  }

  // MARK: - Private

  private func scrollToPendingOrBookmark(animated: Bool) {
    if player.playing { return }
    if let pendingClip = timeline.pendingClips.last {
      scrollToClip(pendingClip, animated: animated)
    } else if let bookmarkedClip = timeline.bookmarkedClip {
      scrollToClip(bookmarkedClip, animated: animated)
    }
  }

  private func setOnboardingAnnotationPlayHidden(hidden: Bool, animated: Bool) {
    if animated {
      UIView.animateWithDuration(0.4) {
        self.setOnboardingAnnotationPlayHidden(hidden, animated: false)
      }
    } else {
      onboardingAnnotationPlay.alpha = CGFloat(!hidden)
    }
  }

  private func setOnboardingAnnotationCaptureHidden(hidden: Bool, animated: Bool) {
    if animated {
      UIView.animateWithDuration(0.4) {
        self.setOnboardingAnnotationCaptureHidden(hidden, animated: false)
      }
    } else {
      onboardingAnnotationCapture.alpha = CGFloat(!hidden)
    }
  }

  private func setOnboardingAnnotationAddHidden(hidden: Bool, animated: Bool) {
    if animated {
      UIView.animateWithDuration(0.4) {
        self.setOnboardingAnnotationAddHidden(hidden, animated: false)
      }
    } else {
      onboardingAnnotationAdd.alpha = CGFloat(!hidden)
    }
  }
}

// MARK: - ClipCollectionViewCellDelegate
extension MainTimelineViewController {

  override func userDidTapAddButtonForCell(cell: ClipCollectionViewCell) {
    let completion = {
      self.setOnboardingAnnotationAddHidden(true, animated: true)
      self.onboardingCompleted = true
      Analytics.track("Create Clip")
      self.setInterfaceFocused(false)
      self.cameraViewController.endPreview()
      self.uploadClipForCell(cell)
    }
    authenticateUser(
      afterSuccessfulAuthentication: {
        self.refresh()
        completion()
      }, whenAlreadyAuthenticated: {
        completion()
    })
  }

  override func userDidTapUserButtonForCell(cell: ClipCollectionViewCell) {
    if cameraViewController.state == CameraViewControllerState.Default {
      super.userDidTapUserButtonForCell(cell)
    }
  }

  override func userDidTapUploadRetryButtonForCell(cell: ClipCollectionViewCell) {
    uploadClipForCell(cell)
  }

  private func uploadClipForCell(cell: ClipCollectionViewCell) {
    if let clip = clipForCell(cell) {
      clip.state = .Uploading
      timeline.markClipAsUpdated(clip)
      API.uploadClip(clip) { (request, response, JSON, error) -> () in
        if let error = error {
          error.alertUser()
          clip.state = ClipState.UploadFailed
        } else {
          clip.state = ClipState.Default
          if let JSON = JSON as? [String: AnyObject] {
            clip.assignAttributes(JSON)
          }
        }
        do { try clip.managedObjectContext?.save() } catch {}
        self.timeline.markClipAsUpdated(clip)
      }
    }
  }
}

// MARK: - CameraViewControllerDelegate
extension MainTimelineViewController: CameraViewControllerDelegate {

  func videoDidBeginRecording() {
    setInterfaceFocused(true)
    setOnboardingAnnotationCaptureHidden(true, animated: true)
  }

  func videoDidEndRecordingToFileAtURL(videoURL: NSURL, thumbnailURL: NSURL) {
    let clip = Clip.newObject() as! Clip
    clip.state = ClipState.PendingUpload
    clip.videoURL = videoURL.absoluteString
    clip.thumbnailURL = thumbnailURL.absoluteString
    clip.user = User.currentUser
    clip.createdAt = NSDate()
    timeline.appendClip(clip)
    scrollToClip(clip, animated: true)
    setOnboardingAnnotationAddHidden(onboardingCompleted, animated: true)
  }

  func videoPreviewDidCancel() {
    setInterfaceFocused(false)
    if let clip = timeline.pendingClips.last {
      timeline.deleteClip(clip)
    }
    setOnboardingAnnotationCaptureHidden(true, animated: true)
    setOnboardingAnnotationAddHidden(true, animated: true)
  }
}

// MARK: - SnowballTopViewDelegate
extension MainTimelineViewController: SnowballTopViewDelegate {

  func snowballTopViewLeftButtonTapped() {
    authenticateUser(
      afterSuccessfulAuthentication: {
        self.refresh()
      }, whenAlreadyAuthenticated: {
        self.switchToNavigationController(MoreNavigationController())
    })
  }

  func snowballTopViewRightButtonTapped() {
    cameraViewController.changeCamera()
  }
}