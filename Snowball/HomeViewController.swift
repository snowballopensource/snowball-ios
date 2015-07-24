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
      Analytics.track("Create Clip")
      self.cameraViewController.endPreview()
      self.uploadClip(clip)
    }
  }

  // MARK: - Private

  private func uploadClip(clip: Clip) {
    clip.state = ClipState.Uploading
    self.clipsViewController.reloadCellForClip(clip)
    API.uploadClip(clip) { (request, response, JSON, error) in
      if let error = error {
        error.print("upload clip")
        self.handleFailedUploadForClip(clip)
      } else {
        self.handleSuccessfulUploadForClip(clip)
      }
    }
  }

  private func handleSuccessfulUploadForClip(clip: Clip) {
    clip.state = ClipState.Default
    self.clipsViewController.reloadCellForClip(clip)
  }

  private func handleFailedUploadForClip(clip: Clip) {
    // TODO: Right now, UploadFailed is not a state on the cell.
    // Awaiting refactor of cell state machine.
    clip.state = ClipState.UploadFailed
    self.clipsViewController.reloadCellForClip(clip)

    // TODO: remove this and replace with textless cell state...
    let alertController = UIAlertController(title: NSLocalizedString("Upload Failed", comment: ""), message: "Want to try again?", preferredStyle: UIAlertControllerStyle.Alert)
    alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel Upload", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil))
    alertController.addAction(UIAlertAction(title: NSLocalizedString("Try Again", comment: ""), style: UIAlertActionStyle.Default, handler: { (action) -> Void in
      self.uploadClip(clip)
    }))
    presentViewController(alertController, animated: true, completion: nil)
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
