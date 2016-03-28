//
//  UserTableViewCell.swift
//  Snowball
//
//  Created by James Martinez on 3/11/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class UserTableViewCell: UITableViewCell {

  // MARK: Properties

  static var defaultHeight: CGFloat = 50

  let userAvatarImageView = UserAvatarImageView()
  let usernameLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.SnowballFont.mediumFont.fontWithSize(17)
    return label
  }()
  let followButton = FollowButton()
  var delegate: UserTableViewCellDelegate?

  // MARK: Initializers

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    addSubview(userAvatarImageView)
    constrain(userAvatarImageView) { userAvatarImageView in
      userAvatarImageView.left == userAvatarImageView.superview!.left + 20
      userAvatarImageView.top == userAvatarImageView.superview!.top + 5
      userAvatarImageView.width == userAvatarImageView.height
      userAvatarImageView.bottom == userAvatarImageView.superview!.bottom - 5
    }

    addSubview(usernameLabel)
    constrain(usernameLabel, userAvatarImageView) { (usernameLabel, userAvatarImageView) in
      usernameLabel.left == userAvatarImageView.right + 13
      usernameLabel.top == usernameLabel.superview!.top
      usernameLabel.bottom == usernameLabel.superview!.bottom
    }

    addSubview(followButton)
    constrain(followButton) { followButton in
      followButton.centerY == followButton.superview!.centerY
      followButton.right == followButton.superview!.right - 20
      followButton.width == FollowButton.defaultSize.width
      followButton.height == FollowButton.defaultSize.height
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  func configureForUser(user: User) {
    userAvatarImageView.setUser(user)

    usernameLabel.text = user.username
    usernameLabel.textColor = user.color

    followButton.configureForUser(user)
    followButton.addTarget(self, action: #selector(UserTableViewCell.followButtonTapped), forControlEvents: .TouchUpInside)
  }

  // MARK: Actions

  @objc private func followButtonTapped() {
    delegate?.userTableViewCellFollowButtonTapped(self)
  }
}

// MARK: -
protocol UserTableViewCellDelegate {
  func userTableViewCellFollowButtonTapped(cell: UserTableViewCell)
}
