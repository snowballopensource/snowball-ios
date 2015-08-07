//
//  ProfileTimelineViewController.swift
//  Snowball
//
//  Created by James Martinez on 7/28/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import Haneke
import UIKit

class ProfileTimelineViewController: TimelineViewController {

  // MARK: - Properties

  private let user: User
  private let userProfileDetailView: UserProfileDetailView

  // MARK: - Initializers

  init(user: User) {
    self.user = user
    self.userProfileDetailView = UserProfileDetailView(user: user)
    super.init(nibName: nil, bundle: nil)
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - UIViewController

  override func loadView() {
    super.loadView()

    view.addSubview(userProfileDetailView)
    layout(userProfileDetailView) { (userProfileDetailView) in
      userProfileDetailView.left == userProfileDetailView.superview!.left
      userProfileDetailView.top == userProfileDetailView.superview!.top
      userProfileDetailView.right == userProfileDetailView.superview!.right
      userProfileDetailView.height == userProfileDetailView.width
    }

    topView = SnowballTopView(leftButtonType: SnowballTopViewButtonType.BackWhite, rightButtonType: nil)
    view.addSubview(topView)
    topView.setupDefaultLayout()
  }

  // MARK: - TimelineViewController

  override func refresh() {
    timeline.requestUserTimeline(user) { (error) -> Void in
      if let error = error {
        println(error)
        // TODO: Display the error
      }
    }
  }
}

// MARK: - TimelineDelegate
extension ProfileTimelineViewController: TimelineDelegate {

  override func timelineClipsDidLoad() {
    super.timelineClipsDidLoad()

    if let lastClip = timeline.clips.last {
      scrollToClip(lastClip, animated: false)
    }
  }
}

// MARK: - SnowballTopViewDelegate
extension ProfileTimelineViewController: SnowballTopViewDelegate {

  func snowballTopViewLeftButtonTapped() {
    navigationController?.popViewControllerAnimated(true)
  }
}

// MARK: -
class UserProfileDetailView: UIView {

  // MARK: - Properties

  private var user: User!
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

  convenience init(user: User) {
    self.init(frame: CGRectZero)

    self.user = user

    userAvatarImageView.configureForUser(user)

    let userColor = user.color as? UIColor ?? UIColor.SnowballColor.blueColor

    backgroundImageView.backgroundColor = userColor
    if let imageURLString = user.avatarURL {
      if let imageURL = NSURL(string: imageURLString) {
        backgroundImageView.hnk_setImageFromURL(imageURL, format: Format<UIImage>(name: "original"))
      }
    }

    usernameLabel.text = user.username
    usernameLabel.textColor = userColor

    configureFollowButton(user)
    followButton.addTarget(self, action: "followButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)

    setupViews()
  }

  // MARK: - Internal

  func setupViews() {
    addSubview(backgroundImageView)
    layout(backgroundImageView) { (backgroundImageView) in
      backgroundImageView.left == backgroundImageView.superview!.left
      backgroundImageView.top == backgroundImageView.superview!.top
      backgroundImageView.right == backgroundImageView.superview!.right
      backgroundImageView.bottom == backgroundImageView.superview!.bottom
    }

    let backgroundBlurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
    backgroundImageView.addSubview(backgroundBlurView)
    layout(backgroundBlurView) { (backgroundBlurView) in
      backgroundBlurView.left == backgroundBlurView.superview!.left
      backgroundBlurView.top == backgroundBlurView.superview!.top
      backgroundBlurView.right == backgroundBlurView.superview!.right
      backgroundBlurView.bottom == backgroundBlurView.superview!.bottom
    }

    addSubview(userAvatarImageView)
    layout(userAvatarImageView) { (userAvatarImageView) in
      userAvatarImageView.centerX == userAvatarImageView.superview!.centerX
      userAvatarImageView.top == userAvatarImageView.superview!.top + 50
      userAvatarImageView.width == 140
      userAvatarImageView.height == userAvatarImageView.width
    }

    addSubview(usernameLabel)
    layout(usernameLabel, userAvatarImageView) { (usernameLabel, userAvatarImageView) in
      usernameLabel.left == usernameLabel.superview!.left
      usernameLabel.top == userAvatarImageView.bottom + 20
      usernameLabel.right == usernameLabel.superview!.right
    }

    addSubview(followButton)
    layout(followButton) { (followButton) in
      followButton.centerX == followButton.superview!.centerX
      followButton.width == 100
      followButton.height == 40
      followButton.bottom == followButton.superview!.bottom - 20
    }
  }

  // MARK: - Private

  private func configureFollowButton(user: User) {
    if let currentUser = User.currentUser {
      if user == currentUser {
        followButton.hidden = true
      } else {
        followButton.hidden = false
        if user.following.boolValue {
          followButton.setTitle(NSLocalizedString("unfollow", comment: ""), forState: UIControlState.Normal)
        } else {
          followButton.setTitle(NSLocalizedString("follow", comment: ""), forState: UIControlState.Normal)
        }
      }
    }
  }

  @objc private func followButtonTapped() {
    // This should probably be a delegate method where the controller does this, but oh well.
    user.toggleFollowing()
    configureFollowButton(user)
  }
}