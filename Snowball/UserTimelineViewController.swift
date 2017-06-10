//
//  UserTimelineViewController.swift
//  Snowball
//
//  Created by James Martinez on 2/17/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Cartography
import Foundation
import UIKit

class UserTimelineViewController: TimelineViewController {

  // MARK: Properties

  fileprivate let topBackgroundImageView = UIImageView()
  fileprivate let usernameLabel: UILabel
  fileprivate let followButton: UIButton
  fileprivate let user: User

  // MARK: Initializers

  init(user: User) {
    self.user = user
    usernameLabel = UILabel()
    followButton = UIButton(type: .custom)
    super.init(timelineType: .user(userID: user.id ?? ""))
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(topBackgroundImageView)
    constrain(topBackgroundImageView) { topBackgroundImageView in
      topBackgroundImageView.left == topBackgroundImageView.superview!.left
      topBackgroundImageView.top == topBackgroundImageView.superview!.top
      topBackgroundImageView.right == topBackgroundImageView.superview!.right
      topBackgroundImageView.height == topBackgroundImageView.superview!.width
    }
    if let avatarURLString = user.avatarURL, let avatarURL = URL(string: avatarURLString) {
      topBackgroundImageView.setImageFromURL(avatarURL)
    }

    setFollowButtonState()
    let followButtonAspectRatio: CGFloat = {
      let contentSize = followButton.intrinsicContentSize
      return contentSize.height / contentSize.width
    }()
    followButton.addTarget(self, action: #selector(followButtonTapped), for: .touchUpInside)
    followButton.isHidden = user.id! == User.currentUser!.id
    view.addSubview(followButton)

    constrain(followButton, topBackgroundImageView) { followButton, topBackgroundImageView in
      followButton.height == followButton.width * followButtonAspectRatio
      followButton.width == 110
      followButton.bottom == topBackgroundImageView.bottom - 20
      followButton.centerX == topBackgroundImageView.centerX
    }

    usernameLabel.font = UIFont.SnowballFont.mediumFont.withSize(30)
    usernameLabel.textAlignment = .center
    usernameLabel.text = user.username
    usernameLabel.textColor = UIColor.white
    view.addSubview(usernameLabel)

    let height = usernameLabel.sizeThatFits(CGSize(width: view.bounds.width, height: CGFloat.greatestFiniteMagnitude)).height

    constrain(usernameLabel, topBackgroundImageView, followButton) { usernameLabel, topBackgroundImageView, followButton in
      usernameLabel.height == height
      usernameLabel.width == topBackgroundImageView.width
      usernameLabel.bottom == followButton.top - 20
      usernameLabel.centerX == topBackgroundImageView.centerX
    }
  }

  fileprivate func setFollowButtonState() {
    let followImage = user.following ? UIImage(imageLiteral: "button-following") : UIImage(imageLiteral: "button-follow")
    followButton.setBackgroundImage(followImage, for: UIControlState())
  }

  @objc func followButtonTapped() {
    followForUser(user) { following in
      self.setFollowButtonState()
    }
  }

  // MARK: TimelinePlayerDelegate Overrides
  // This is because swift does not allow overrides in extensions. Sorry!

  override func timelinePlayer(_ timelinePlayer: TimelinePlayer, willBeginPlaybackWithFirstClip clip: Clip) {
    super.timelinePlayer(timelinePlayer, willBeginPlaybackWithFirstClip: clip)
    view.sendSubview(toBack: topBackgroundImageView)
    view.sendSubview(toBack: usernameLabel)
    view.sendSubview(toBack: followButton)
  }

  override func timelinePlayer(_ timelinePlayer: TimelinePlayer, didEndPlaybackWithLastClip clip: Clip) {
    super.timelinePlayer(timelinePlayer, didEndPlaybackWithLastClip: clip)
    view.bringSubview(toFront: topBackgroundImageView)
    view.bringSubview(toFront: usernameLabel)
    view.bringSubview(toFront: followButton)
  }
}
