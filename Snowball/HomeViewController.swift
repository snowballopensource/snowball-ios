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
    clipsViewController.playerViewController.endPlayback()
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
    clip.user = User.currentUser
    clip.createdAt = NSDate()
    clipsViewController.previewClip(clip)
  }
}