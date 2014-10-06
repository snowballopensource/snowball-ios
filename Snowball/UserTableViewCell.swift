//
//  UserTableViewCell.swift
//  Snowball
//
//  Created by James Martinez on 9/29/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

protocol UserTableViewCellDelegate: class {
  func settingsButtonTapped()
}

class UserTableViewCell: UITableViewCell {
  private let nameLabel = UILabel()
  private let usernameLabel = UILabel()
  private let avatarImageView = UserImageView()
  private let settingsButton = UIButton()
  var delegate: UserTableViewCellDelegate?

  // MARK: -

  // MARK: UITableViewCell

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    selectionStyle = UITableViewCellSelectionStyle.None
    contentView.backgroundColor = UIColor.whiteColor()
    nameLabel.font = nameLabel.font.fontWithSize(19.0)
    contentView.addSubview(nameLabel)
    usernameLabel.font = usernameLabel.font.fontWithSize(12.0)
    contentView.addSubview(usernameLabel)
    contentView.addSubview(avatarImageView)
    settingsButton.setTitle(NSLocalizedString("Settings"), forState: UIControlState.Normal)
    settingsButton.setTitleColorWithAutomaticHighlightColor(color: UIColor.SnowballColor.blue())
    settingsButton.addTarget(delegate, action: "settingsButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    contentView.addSubview(settingsButton)
  }

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  override class func height() -> CGFloat {
    return 60.0
  }

  override func configureForObject(object: AnyObject) {
    let user = object as User
    nameLabel.text = user.name
    nameLabel.textColor = user.color
    usernameLabel.text = user.username
    usernameLabel.textColor = user.color
    avatarImageView.setUser(user)
    settingsButton.hidden = true
    if user == User.currentUser {
      settingsButton.hidden = false
    }
  }

  // MARK: UIView

  override func layoutSubviews() {
    super.layoutSubviews()

    layout(avatarImageView) { (avatarImageView) in
      avatarImageView.top == avatarImageView.superview!.top + 10
      avatarImageView.left == avatarImageView.superview!.left + 16
      let sideLength: Float = 40
      avatarImageView.width == sideLength
      avatarImageView.height == sideLength
    }
    layout(nameLabel, avatarImageView) { (nameLabel, avatarImageView) in
      nameLabel.top == avatarImageView.top
      nameLabel.left == avatarImageView.right + 12
    }
    layout(usernameLabel, avatarImageView) { (usernameLabel, avatarImageView) in
      usernameLabel.bottom == avatarImageView.bottom
      usernameLabel.left == avatarImageView.right + 12
    }
    layout(settingsButton) { (settingsButton) in
      settingsButton.centerY == settingsButton.superview!.centerY
      settingsButton.right == settingsButton.superview!.right - 16
    }
  }
}
