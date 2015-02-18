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
  let topMenuView = UIView()
  let moreButton: UIButton = {
    let moreButton = UIButton()
    moreButton.setImage(UIImage(named: "friends"), forState: UIControlState.Normal)
    return moreButton
  }()
  let changeCameraButton: UIButton = {
    let changeCameraButton = UIButton()
    changeCameraButton.setImage(UIImage(named: "change-camera"), forState: UIControlState.Normal)
    return changeCameraButton
  }()

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.blackColor()

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

    view.addSubview(topMenuView)
    layout(topMenuView) { (topMenuView) in
      topMenuView.left == topMenuView.superview!.left
      topMenuView.top == topMenuView.superview!.top
      topMenuView.width == topMenuView.superview!.width
      topMenuView.height == 55
    }

    moreButton.addTarget(self, action: "moreButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    topMenuView.addSubview(moreButton)
    layout(moreButton) { (moreButton) in
      let margin: Float = 10
      let width: Float = 44
      moreButton.left == moreButton.superview!.left + margin
      moreButton.top == moreButton.superview!.top + margin
      moreButton.width == width
      moreButton.height == width
    }

    changeCameraButton.addTarget(self, action: "changeCameraButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    topMenuView.addSubview(changeCameraButton)
    layout(changeCameraButton) { (changeCameraButton) in
      let margin: Float = 10
      let width: Float = 44
      changeCameraButton.right == changeCameraButton.superview!.right - margin
      changeCameraButton.top == changeCameraButton.superview!.top + margin
      changeCameraButton.width == width
      changeCameraButton.height == width
    }
  }

  // MARK: - Private

  @objc private func moreButtonTapped() {
    clipsViewController.playerViewController.endPlayback()
    AppDelegate.switchToNavigationController(MoreNavigationController())
  }

  @objc private func changeCameraButtonTapped() {
    cameraViewController.changeCamera()
  }

  private func showTopMenuViewAnimated() {
    UIView.animateWithDuration(0.4) {
      let frame = self.topMenuView.frame
      let newFrame = CGRect(x: frame.origin.x, y: 0, width: frame.width, height: frame.height)
      self.topMenuView.frame = newFrame
    }
  }

  private func hideTopMenuViewAnimated() {
    UIView.animateWithDuration(0.4) {
      let frame = self.topMenuView.frame
      let newFrame = CGRect(x: frame.origin.x, y: -frame.height, width: frame.width, height: frame.height)
      self.topMenuView.frame = newFrame
    }
  }

}


// MARK: -

extension HomeViewController: ClipsViewControllerDelegate {

  // MARK: - ClipsViewControllerDelegate

  func willBeginPlayback() {
    cameraViewController.view.hidden = true
    hideTopMenuViewAnimated()
  }

  func didEndPlayback() {
    cameraViewController.view.hidden = false
    showTopMenuViewAnimated()
  }
}

// MARK: - 

extension HomeViewController: CameraViewControllerDelegate {

  // MARK: - CameraViewControllerDelegate

  func videoRecordedToFileAtURL(videoURL: NSURL, thumbnailURL: NSURL, error: NSError?) {
    error?.print("recording")
    let clip = Clip()
    clip.videoURL = videoURL
    clip.thumbnailURL = thumbnailURL
    clip.user = User.currentUser
    clip.createdAt = NSDate()
    clipsViewController.previewClip(clip)
  }
}