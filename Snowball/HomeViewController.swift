//
//  HomeViewController.swift
//  Snowball
//
//  Created by James Martinez on 3/2/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKIt

class HomeViewController: UIViewController {

  // MARK: - Properties

  let topView = SnowballTopView(leftButtonType: SnowballTopViewButtonType.Friends, rightButtonType: SnowballTopViewButtonType.ChangeCamera)
  let clipsViewController = ClipsViewController()
  let cameraViewController = CameraViewController()

  private let kHasSeenOnboardingKey = "HasSeenOnboarding"
  var hasSeenOnboarding: Bool {
    get {
      return NSUserDefaults.standardUserDefaults().objectForKey(kHasSeenOnboardingKey) as? Bool ?? false
    }
    set {
      NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: kHasSeenOnboardingKey)
      NSUserDefaults.standardUserDefaults().synchronize()
    }
  }

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    clipsViewController.delegate = self
    addChildViewController(clipsViewController)
    view.addSubview(clipsViewController.view)
    clipsViewController.didMoveToParentViewController(self)
    clipsViewController.view.frame == view.bounds

    cameraViewController.delegate = self
    addChildViewController(cameraViewController)
    view.addSubview(cameraViewController.view)
    cameraViewController.didMoveToParentViewController(self)
    layout(cameraViewController.view) { (cameraView) in
      cameraView.left == cameraView.superview!.left
      cameraView.top == cameraView.superview!.top
      cameraView.right == cameraView.superview!.right
      cameraView.height == cameraView.width
    }

    view.addSubview(topView)
    topView.setupDefaultLayout()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    if !hasSeenOnboarding {
      presentViewController(OnboardingPageViewController(), animated: true) {
        self.hasSeenOnboarding = true
      }
    }
  }
}

// MARK: -

extension HomeViewController: ClipsViewControllerDelegate {

  // MARK: - ClipsViewControllerDelegate

  func playerWillBeginPlayback() {
    cameraViewController.view.hidden = true
    topView.setHidden(true, animated: true)
  }

  func playerDidEndPlayback() {
    cameraViewController.view.hidden = false
    topView.setHidden(false, animated: true)
  }

  func userDidAcceptPreviewClip(clip: Clip) {
    cameraViewController.view.hidden = false
    topView.setHidden(false, animated: true)
    if clip.id == nil {
      clip.state = ClipState.Default
      self.clipsViewController.reloadCellForClip(clip)
      self.cameraViewController.endPreview()
      self.uploadClip(clip)
    }
  }

  // MARK: - Private

  private func uploadClip(clip: Clip) {
    Analytics.track("Create Clip")
    API.uploadClip(clip) { (request, response, JSON, error) in
      if let error = error {
        error.print("upload clip")
        displayAPIErrorToUser(JSON)
      }
    }
  }
}

// MARK: -

extension HomeViewController: CameraViewControllerDelegate {

  // MARK: - CameraViewControllerDelegate

  func videoDidBeginRecording() {
    topView.setHidden(true, animated: true)
  }

  func videoDidEndRecordingToFileAtURL(videoURL: NSURL, thumbnailURL: NSURL) {
    let clip = Clip()
    clip.state = ClipState.Pending
    clip.videoURL = videoURL
    clip.thumbnailURL = thumbnailURL
    clip.user = User.currentUser
    clip.createdAt = NSDate()
    clipsViewController.addClipToTimeline(clip)
  }

  func videoPreviewDidCancel() {
    clipsViewController.removePendingClipFromTimeline()
    topView.setHidden(false, animated: true)
  }
}

// MARK: -

extension HomeViewController: SnowballTopViewDelegate {

  // MARK: - SnowballTopViewDelegate

  func snowballTopViewLeftButtonTapped() {
    switchToNavigationController(MoreNavigationController())
  }

  func snowballTopViewRightButtonTapped() {
    cameraViewController.changeCamera()
  }
}
