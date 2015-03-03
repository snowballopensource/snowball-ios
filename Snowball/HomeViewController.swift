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
  }
}

// MARK: -

extension HomeViewController: ClipsViewControllerDelegate {

  // MARK: - ClipsViewControllerDelegate

  func playerWillBeginPlayback() {
    cameraViewController.view.hidden = true
  }

  func playerDidEndPlayback() {
    cameraViewController.view.hidden = false
  }

  func userDidAcceptPreviewClip(clip: Clip) {
    cameraViewController.view.hidden = false
    uploadClip(clip)
  }

  // MARK: - Private

  private func uploadClip(clip: Clip) {
    if clip.id == nil {
      clip.state = ClipState.Default
      self.clipsViewController.reloadCellForClip(clip)
      Analytics.track("Create Clip")
      API.uploadClip(clip) { (request, response, JSON, error) in
        if let error = error {
          error.print("upload clip")
          displayAPIErrorToUser(JSON)
        }
      }
    }
  }
}

// MARK: -

extension HomeViewController: CameraViewControllerDelegate {

  // MARK: - CameraViewControllerDelegate

  func videoDidBeginRecording() {
    // TODO: hide navigation bar
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
    // TODO: show navigation bar
  }
}
