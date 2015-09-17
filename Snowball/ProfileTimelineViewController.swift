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

    self.userProfileDetailView.delegate = self
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - UIViewController

  override func loadView() {
    super.loadView()

    view.addSubview(userProfileDetailView)
    constrain(userProfileDetailView) { (userProfileDetailView) in
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
        print(error)
        // TODO: Display the error
      }
    }
  }

  // MARK: - TimelinePlayerDelegate
  // See the comment in TimelineViewController for the TimelinePlayer delegate
  // to see why this is here. It's such a confusing mess. Sorry future self!
  override func timelinePlayer(timelinePlayer: TimelinePlayer, didBeginPlayingWithClip clip: Clip) {
    super.timelinePlayer(timelinePlayer, didBeginPlayingWithClip: clip)
    userProfileDetailView.hidden = true
  }

  override func timelinePlayer(timelinePlayer: TimelinePlayer, didEndPlayingLastClip lastClip: Clip) {
    super.timelinePlayer(timelinePlayer, didEndPlayingLastClip: lastClip)
    userProfileDetailView.hidden = false
  }
}

// MARK: - TimelineDelegate
extension ProfileTimelineViewController {

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

// MARK: - ClipCollectionViewCellDelegate
extension ProfileTimelineViewController {

  // Prevent going to profile again from the profile
  override func userDidTapUserButtonForCell(cell: ClipCollectionViewCell) {}
}

// MARK: - UserProfileDetailViewDelegate
extension ProfileTimelineViewController: UserProfileDetailViewDelegate {

  func userDidSwipeHideProfileGestureRecognizer() {
    navigationController?.popViewControllerAnimated(true)
  }
}

// MARK: -
protocol UserProfileDetailViewDelegate {
  func userDidSwipeHideProfileGestureRecognizer()
}

// MARK: -
class UserProfileDetailView: UIView {

  // MARK: - Properties

  var delegate: UserProfileDetailViewDelegate?

  private var user: User!
  private let backgroundImageView = UIImageView()
  private let backgroundImageViewGradient: CAGradientLayer = {
    let gradientLayer = CAGradientLayer()
    let color1 = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).CGColor as CGColorRef
    let color2 = UIColor.clearColor().CGColor as CGColorRef
    let color3 = UIColor.clearColor().CGColor as CGColorRef
    let color4 = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6).CGColor as CGColorRef
    gradientLayer.colors = [color1, color2, color3, color4]
    return gradientLayer
    }()
  private let hideProfileGestureRecognizer: UISwipeGestureRecognizer = {
    let swipeGestureRecognizer = UISwipeGestureRecognizer()
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
    return swipeGestureRecognizer
    }()
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

    let userColor = user.color as? UIColor ?? UIColor.SnowballColor.blueColor

    backgroundImageView.backgroundColor = userColor.darkVersion()
    if let imageURLString = user.avatarURL {
      if let imageURL = NSURL(string: imageURLString) {
        backgroundImageView.setImageFromURL(imageURL)
      }
    }

    hideProfileGestureRecognizer.addTarget(self, action: "hideProfileGestureRecognizerSwiped")
    backgroundImageView.addGestureRecognizer(hideProfileGestureRecognizer)
    backgroundImageView.userInteractionEnabled = true

    usernameLabel.text = user.username
    usernameLabel.textColor = userColor

    configureFollowButton(user)
    followButton.addTarget(self, action: "followButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)

    setupViews()
  }

  // MARK: - Internal

  func setupViews() {
    addSubview(backgroundImageView)
    constrain(backgroundImageView) { (backgroundImageView) in
      backgroundImageView.left == backgroundImageView.superview!.left
      backgroundImageView.top == backgroundImageView.superview!.top
      backgroundImageView.right == backgroundImageView.superview!.right
      backgroundImageView.bottom == backgroundImageView.superview!.bottom
    }

    backgroundImageView.layer.addSublayer(backgroundImageViewGradient)

    addSubview(followButton)
    constrain(followButton) { (followButton) in
      followButton.centerX == followButton.superview!.centerX
      followButton.width == 100
      followButton.height == 40
      followButton.bottom == followButton.superview!.bottom - 20
    }

    addSubview(usernameLabel)
    constrain(usernameLabel, followButton) { (usernameLabel, followButton) in
      usernameLabel.left == usernameLabel.superview!.left
      usernameLabel.bottom == followButton.top - 20
      usernameLabel.right == usernameLabel.superview!.right
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    backgroundImageViewGradient.frame = backgroundImageView.bounds
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

  @objc private func hideProfileGestureRecognizerSwiped() {
    delegate?.userDidSwipeHideProfileGestureRecognizer()
  }
}