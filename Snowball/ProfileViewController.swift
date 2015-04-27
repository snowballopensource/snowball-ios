//
//  ProfileViewController.swift
//  Snowball
//
//  Created by James Martinez on 4/23/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import Haneke
import UIKit

class ProfileViewController: UIViewController {

  // MARK: - Properties

  private let topView = SnowballTopView(leftButtonType: SnowballTopViewButtonType.BackWhite, rightButtonType: nil)

  private let clipsViewController: ProfileClipsViewController

  private var user: User {
    get {
      return clipsViewController.user
    }
  }

  private let topProfileView = UIView()

  private let backgroundImageView = UIImageView()

  private let userAvatarImageView = UserAvatarImageView()

  private let usernameLabel: UILabel = {
    let label = UILabel()
    var fontSize: CGFloat = 28
    label.font = UIFont(name: UIFont.SnowballFont.bold, size: fontSize)
    label.textAlignment = NSTextAlignment.Center
    return label
  }()

  private let followButton: UIButton = {
    let button = UIButton()
    button.titleLabel?.font = UIFont(name: UIFont.SnowballFont.bold, size: 18)
    button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    button.layer.cornerRadius = 20
    button.layer.borderWidth = 2
    button.layer.borderColor = UIColor.whiteColor().CGColor
    return button
  }()

  // MARK: - Initializers

  init(user: User) {
    clipsViewController = ProfileClipsViewController(user: user)

    userAvatarImageView.configureForUser(user)

    let userColor = user.color as? UIColor ?? UIColor.SnowballColor.greenColor

    backgroundImageView.backgroundColor = userColor
    if let imageURLString = user.avatarURL {
      if let imageURL = NSURL(string: imageURLString) {
        backgroundImageView.hnk_setImageFromURL(imageURL, format: Format<UIImage>(name: "original"))
      }
    }

    usernameLabel.text = user.username
    usernameLabel.textColor = userColor

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

    view.addSubview(topProfileView)

    layout(topProfileView, clipsViewController.collectionView) { (topProfileView, collectionView) in
      topProfileView.left == topProfileView.superview!.left
      topProfileView.top == topProfileView.superview!.top
      topProfileView.right == topProfileView.superview!.right
      topProfileView.bottom == collectionView.top
    }

    topProfileView.addSubview(backgroundImageView)
    backgroundImageView.frame = topProfileView.bounds

    let backgroundBlurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
    backgroundBlurView.frame = backgroundImageView.bounds
    backgroundImageView.addSubview(backgroundBlurView)

    topProfileView.addSubview(userAvatarImageView)
    layout(userAvatarImageView) { (userAvatarImageView) in
      userAvatarImageView.centerX == userAvatarImageView.superview!.centerX
      userAvatarImageView.top == userAvatarImageView.superview!.top + 50
      userAvatarImageView.width == 140
      userAvatarImageView.height == userAvatarImageView.width
    }

    topProfileView.addSubview(usernameLabel)
    layout(usernameLabel, userAvatarImageView) { (usernameLabel, userAvatarImageView) in
      usernameLabel.left == usernameLabel.superview!.left
      usernameLabel.top == userAvatarImageView.bottom + 20
      usernameLabel.right == usernameLabel.superview!.right
    }

    followButton.addTarget(self, action: "followButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    configureFollowButton()
    topProfileView.addSubview(followButton)
    layout(followButton) { (followButton) in
      followButton.centerX == followButton.superview!.centerX
      followButton.width == 100
      followButton.height == 40
      followButton.bottom == followButton.superview!.bottom - 20
    }

    view.addSubview(topView)
    topView.setupDefaultLayout()
  }

  // MARK: - Private

  private func configureFollowButton() {
    if let currentUser = User.currentUser {
      if user == currentUser {
        followButton.hidden = true
      } else {
        followButton.hidden = false
        if user.following.boolValue {
          followButton.setTitle(NSLocalizedString("unfollow"), forState: UIControlState.Normal)
        } else {
          followButton.setTitle(NSLocalizedString("follow"), forState: UIControlState.Normal)
        }
      }
    }
  }

  @objc private func followButtonTapped() {
    user.toggleFollowing()
    configureFollowButton()
  }
}

// MARK: -

extension ProfileViewController: ClipsViewControllerDelegate {

  // MARK: - ClipsViewControllerDelegate

  func playerShouldBeginPlayback() -> Bool {
    return true
  }

  func playerWillBeginPlayback() {
    topProfileView.hidden = true
    topView.setHidden(true, animated: true)
  }

  func playerDidEndPlayback() {
    topProfileView.hidden = false
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