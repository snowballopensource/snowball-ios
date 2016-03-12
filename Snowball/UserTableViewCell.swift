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

  let userAvatarImageView = UserAvatarImageView()
  let usernameLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.SnowballFont.mediumFont.fontWithSize(14)
    return label
  }()

  // MARK: Initializers

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    addSubview(userAvatarImageView)
    constrain(userAvatarImageView) { userAvatarImageView in
      userAvatarImageView.left == userAvatarImageView.superview!.left + 10
      userAvatarImageView.top == userAvatarImageView.superview!.top + 10
      userAvatarImageView.width == userAvatarImageView.height
      userAvatarImageView.bottom == userAvatarImageView.superview!.bottom - 10
    }

    addSubview(usernameLabel)
    constrain(usernameLabel, userAvatarImageView) { (usernameLabel, userAvatarImageView) in
      usernameLabel.left == userAvatarImageView.right + 10
      usernameLabel.top == usernameLabel.superview!.top
      usernameLabel.bottom == usernameLabel.superview!.bottom
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
