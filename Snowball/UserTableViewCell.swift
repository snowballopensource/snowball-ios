//
//  UserTableViewCell.swift
//  Snowball
//
//  Created by James Martinez on 1/27/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import Haneke
import UIKit

protocol UserTableViewCellDelegate: class {
  func followUserButtonTappedInCell(cell: UserTableViewCell)
}

class UserTableViewCell: UITableViewCell {
  var delegate: UserTableViewCellDelegate?
  private let avatarImageView = UserAvatarImageView()
  private let usernameLabel = UILabel()
  private let followButton: UIButton = {
    let followButton = UIButton()
    followButton.titleLabel?.font = UIFont(name: UIFont.SnowballFont.bold, size: 18)
    followButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    followButton.layer.cornerRadius = 20
    return followButton
  }()

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(avatarImageView)
    usernameLabel.font = UIFont(name: UIFont.SnowballFont.regular, size: 26)
    contentView.addSubview(usernameLabel)
    followButton.addTarget(self, action: "followButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    contentView.addSubview(followButton)
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - UIView

  override func layoutSubviews() {
    super.layoutSubviews()

    let margin: Float = 20
    layout(avatarImageView) { (avatarImageView) in
      avatarImageView.left == avatarImageView.superview!.left + margin
      avatarImageView.centerY == avatarImageView.superview!.centerY
      avatarImageView.width == 40
      avatarImageView.height == avatarImageView.width
    }

    layout(usernameLabel, avatarImageView) { (usernameLabel, avatarImageView) in
      usernameLabel.left == avatarImageView.right + 15
      usernameLabel.centerY == usernameLabel.superview!.centerY
      usernameLabel.right == usernameLabel.superview!.right
    }

    layout(followButton) { (followButton) in
      followButton.width == 100
      followButton.centerY == followButton.superview!.centerY
      followButton.right == followButton.superview!.right - margin
      followButton.height == 40
    }
  }

  // MARK: - UICollectionReuseableView+Required

  override class var height: CGFloat {
    return 55
  }

  override func configureForObject(object: AnyObject) {
    let user = object as User
    usernameLabel.text = user.username
    let userColor = user.color as UIColor
    avatarImageView.backgroundColor = userColor
    usernameLabel.textColor = userColor
    var color: UIColor!
    if user.following.boolValue {
      color = UIColor.SnowballColor.grayColor
      followButton.setTitle(NSLocalizedString("unfollow"), forState: UIControlState.Normal)
    } else {
      color = UIColor.SnowballColor.greenColor
      followButton.setTitle(NSLocalizedString("follow"), forState: UIControlState.Normal)
    }
    followButton.backgroundColor = color
  }

  // MARK: - Private

  @objc private func followButtonTapped() {
    delegate?.followUserButtonTappedInCell(self)
  }
}
