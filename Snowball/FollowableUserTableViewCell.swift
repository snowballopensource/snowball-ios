//
//  FollowableUserTableViewCell.swift
//  Snowball
//
//  Created by James Martinez on 10/9/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Foundation

import Cartography
import Foundation

protocol FollowableUserTableViewCellDelegate: class {
  func followButtonTapped()
}

class FollowableUserTableViewCell: UserTableViewCell {
  private let followButton = UIButton()
  var delegate: FollowableUserTableViewCellDelegate?

  // MARK: -

  // MARK: UserTableViewCell

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    followButton.setTitle(NSLocalizedString("Follow"), forState: UIControlState.Normal)
    followButton.setTitleColorWithAutomaticHighlightColor(color: UIColor.SnowballColor.blue())
    followButton.addTarget(delegate, action: "followButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    contentView.addSubview(followButton)
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: UIView

  override func layoutSubviews() {
    super.layoutSubviews()

    layout(followButton) { (followButton) in
      followButton.centerY == followButton.superview!.centerY
      followButton.right == followButton.superview!.right - 16
    }
  }
  
}