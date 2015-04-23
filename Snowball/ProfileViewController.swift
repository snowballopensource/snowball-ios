//
//  ProfileViewController.swift
//  Snowball
//
//  Created by James Martinez on 4/23/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class ProfileViewController: UIViewController {

  // MARK: - Properties

  let topView = SnowballTopView(leftButtonType: SnowballTopViewButtonType.Back, rightButtonType: nil)

  let clipsViewController: ProfileClipsViewController

  // MARK: - Initializers

  init(user: User) {
    clipsViewController = ProfileClipsViewController(user: user)
    super.init(nibName: nil, bundle: nil)
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.whiteColor()

    clipsViewController.delegate = self
    addChildViewController(clipsViewController)
    view.addSubview(clipsViewController.view)
    clipsViewController.didMoveToParentViewController(self)
    clipsViewController.view.frame == view.bounds

    view.addSubview(topView)
    topView.setupDefaultLayout()
  }
}

// MARK: -

extension ProfileViewController: ClipsViewControllerDelegate {

  // MARK: - ClipsViewControllerDelegate

  func playerShouldBeginPlayback() -> Bool {
    return true
  }

  func playerWillBeginPlayback() {
    topView.setHidden(true, animated: true)
  }

  func playerDidEndPlayback() {
    topView.setHidden(false, animated: true)
  }

  func userDidAcceptPreviewClip(clip: Clip) {}
}

// MARK: -

extension ProfileViewController: SnowballTopViewDelegate {

  // MARK: - SnowballTopViewDelegate

  func snowballTopViewLeftButtonTapped() {
    navigationController?.popViewControllerAnimated(true)
  }
}