//
//  HomeViewController.swift
//  Snowball
//
//  Created by James Martinez on 2/9/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class HomeViewController: UIViewController {

  // MARK: - Properties

  let cameraViewController = CameraViewController()
  let clipsViewController = ClipsViewController()
  let moreButton: UIButton = {
    let moreButton = UIButton()
    moreButton.setImage(UIImage(named: "friends"), forState: UIControlState.Normal)
    return moreButton
  }()

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    clipsViewController.delegate = self
    addChildViewController(clipsViewController)
    view.addSubview(clipsViewController.view)
    clipsViewController.didMoveToParentViewController(self)
    clipsViewController.view.frame == view.frame

    cameraViewController.delegate = self
    addChildViewController(cameraViewController)
    view.addSubview(cameraViewController.view)
    cameraViewController.didMoveToParentViewController(self)
    layout(cameraViewController.view) { (cameraViewControllerView) in
      cameraViewControllerView.left == cameraViewControllerView.superview!.left
      cameraViewControllerView.top == cameraViewControllerView.superview!.top
      cameraViewControllerView.right == cameraViewControllerView.superview!.right
      cameraViewControllerView.height == cameraViewControllerView.superview!.width
    }

    moreButton.addTarget(self, action: "moreButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    view.addSubview(moreButton)
    layout(moreButton) { (moreButton) in
      let margin: Float = 10
      let width: Float = 44
      moreButton.left == moreButton.superview!.left + margin
      moreButton.top == moreButton.superview!.top + margin
      moreButton.width == width
      moreButton.height == width
    }
  }

  // MARK: - Private

  @objc private func moreButtonTapped() {
    AppDelegate.switchToNavigationController(MoreNavigationController())
  }

}


// MARK: -

extension HomeViewController: ClipsViewControllerDelegate {

  // MARK: - ClipsViewControllerDelegate

  func willBeginPlayback() {
    cameraViewController.view.hidden = true
  }

  func didEndPlayback() {
    cameraViewController.view.hidden = false
  }
}

// MARK: - 

extension HomeViewController: CameraViewControllerDelegate {

  // MARK: - CameraViewControllerDelegate

  func videoRecordedToFileAtURL(videoURL: NSURL, thumbnailURL: NSURL, error: NSError?) {
    error?.print("recording")
    let clip = NewClip()
    clip.videoURL = videoURL
    clip.thumbnailURL = thumbnailURL
    clipsViewController.previewClip(clip)
  }
}

//  func userCancelledClipPreviewPlayback() {
//    clipsViewController.hideAddClipButton()
//    stopPlaybackAndShowCamera()
//  }
//
//  // MARK: - CameraViewControllerDelegate
//
//  func videoRecordedToFileAtURL(videoURL: NSURL, thumbnailURL: NSURL, error: NSError?) {
//    error?.print("recording")
//    cameraViewController.view.hidden = true
//    clipsViewController.showAddClipButton()
//    previewedVideoURL = videoURL
//    previewedVideoThumbnailURL = thumbnailURL
//    playerViewController.playLocalURL(videoURL)
//  }
//
//  // MARK: - ClipsViewControllerDelegate
//
//  func clipSelected(clip: Clip) {
//    let clips = Clip.playableClips(since: clip.createdAt)
//    let videoURLs = clips.map { clip -> NSURL in
//      return NSURL(string: clip.videoURL)!
//    }
//    cameraViewController.view.hidden = true
//    playerViewController.playURLs(videoURLs)
//  }
//
//  func addClipButtonTapped() {
//    stopPlaybackAndShowCamera()
//    clipsViewController.hideAddClipButton()
//    if let currentUser = User.currentUser {
//      if let videoURL = self.previewedVideoURL {
//        if let thumbnailURL = self.previewedVideoThumbnailURL {
//          let clip = Clip.newEntity() as Clip
//          clip.videoURL = videoURL.absoluteString!
//          clip.thumbnailURL = thumbnailURL.absoluteString!
//          clip.user = currentUser
//          clip.createdAt = NSDate()
//          clip.save()
//          clipsViewController.scrollToClip(clip)
//          API.uploadClip(clip) { (request, response, JSON, error) in
//            if error != nil { displayAPIErrorToUser(JSON); return }
//            if let clipJSON: AnyObject = JSON {
//              dispatch_async(dispatch_get_main_queue()) {
//                clip.assign(clipJSON)
//                clip.save()
//              }
//            }
//          }
//        }
//      }
//    }
//  }
//}