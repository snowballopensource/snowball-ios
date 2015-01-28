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

//protocol UserTableViewCellDelegate: class {
//  func followUserButtonTappedInCell(cell: UserTableViewCell)
//}

class UserTableViewCell: UITableViewCell {
  // var delegate: UserTableViewCellDelegate?
  private let avatarImageView = UserAvatarImageView()
  private let usernameLabel = UILabel()

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(avatarImageView)
    usernameLabel.font = UIFont(name: UIFont.SnowballFont.regular, size: 26)
    contentView.addSubview(usernameLabel)
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
  }

  // MARK: - UICollectionReuseableView+Required

  override class func height() -> CGFloat {
    return 55
  }

  override func configureForObject(object: AnyObject) {
    let user = object as User
    usernameLabel.text = user.username
    let userColor = user.color as UIColor
    avatarImageView.backgroundColor = userColor
    usernameLabel.textColor = userColor
  }
}
