//
//  HomeViewController.swift
//  Snowball
//
//  Created by James Martinez on 3/2/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class HomeViewController: UIViewController {

  // MARK: - Properties

  let topView = SnowballTopView(leftButtonType: SnowballTopViewButtonType.Friends, rightButtonType: SnowballTopViewButtonType.ChangeCamera)
  let clipsViewController = ClipsViewController()
  let cameraViewController = CameraViewController()

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
}

// MARK: -

extension HomeViewController: ClipsViewControllerDelegate {

  // MARK: - ClipsViewControllerDelegate

  func playerShouldBeginPlayback() -> Bool {
    return cameraViewController.state == CameraViewControllerState.Default
  }

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
    clipsViewController.prepareForClipPreview(starting: false)
    topView.setHidden(false, animated: true)
    if clip.id == nil {
      clip.state = ClipState.Uploading
      self.clipsViewController.reloadCellForClip(clip)
      self.cameraViewController.endPreview()
      self.uploadClip(clip) { (success) in
        if success {
          println("clip upload succeeded")
          clip.state = ClipState.Default
        } else {
          println("clip upload failed")
        }
      }
    }
  }

  // MARK: - Private

  private func uploadClip(clip: Clip, completion: (success: Bool) -> Void) {
    Analytics.track("Create Clip")
    API.uploadClip(clip) { (request, response, JSON, error) in
      if let error = error {
        error.print("upload clip")
        displayAPIErrorToUser(JSON)
        completion(success: false)
      } else {
        completion(success: true)
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
    clipsViewController.prepareForClipPreview(starting: true)
    clipsViewController.addClipToTimeline(clip)
  }

  func videoPreviewDidCancel() {
    clipsViewController.prepareForClipPreview(starting: false)
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
