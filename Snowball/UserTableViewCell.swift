//
//  UserTableViewCell.swift
//  Snowball
//
//  Created by James Martinez on 1/27/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

protocol UserTableViewCellDelegate: class {
  func followUserButtonTappedInCell(cell: UserTableViewCell)
}

class UserTableViewCell: UITableViewCell {

  // MARK: - Properties

  class var height: CGFloat {
    return 55
  }

  var delegate: UserTableViewCellDelegate?

  private let avatarImageView = UserAvatarImageView()

  private let usernameLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: UIFont.SnowballFont.bold, size: 19)
    return label
  }()

  private let followButton: UIButton = {
    let button = UIButton()
    button.titleLabel?.font = UIFont(name: UIFont.SnowballFont.bold, size: 14)
    button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    button.layer.cornerRadius = 20
    return button
  }()

  // MARK: - Initializers

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    let margin: Float = 20

    contentView.addSubview(avatarImageView)
    constrain(avatarImageView) { (avatarImageView) in
      avatarImageView.left == avatarImageView.superview!.left + margin
      avatarImageView.centerY == avatarImageView.superview!.centerY
      avatarImageView.width == 40
      avatarImageView.height == avatarImageView.width
    }

    contentView.addSubview(usernameLabel)
    constrain(usernameLabel, avatarImageView) { (usernameLabel, avatarImageView) in
      usernameLabel.left == avatarImageView.right + 15
      usernameLabel.centerY == usernameLabel.superview!.centerY
      usernameLabel.right == usernameLabel.superview!.right
    }

    followButton.addTarget(self, action: "followButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    contentView.addSubview(followButton)
    constrain(followButton) { (followButton) in
      followButton.width == 80
      followButton.centerY == followButton.superview!.centerY
      followButton.right == followButton.superview!.right - margin
      followButton.height == 40
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Internal

  func configureForObject(object: AnyObject) {
    let user = object as! User
    usernameLabel.text = user.username
    let userColor = user.color as! UIColor
    avatarImageView.configureForUser(user)
    usernameLabel.textColor = userColor
    if user.following.boolValue {
      followButton.setTitle(NSLocalizedString("unfollow", comment: ""), forState: UIControlState.Normal)
      followButton.backgroundColor = UIColor.SnowballColor.grayColor
    } else {
      followButton.setTitle(NSLocalizedString("follow", comment: ""), forState: UIControlState.Normal)
      followButton.backgroundColor = userColor
    }
  }

  // MARK: - Private

  @objc private func followButtonTapped() {
    delegate?.followUserButtonTappedInCell(self)
  }
}
