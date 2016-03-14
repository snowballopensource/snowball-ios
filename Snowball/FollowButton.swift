//
//  FollowButton.swift
//  Snowball
//
//  Created by James Martinez on 3/14/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import UIKit

class FollowButton: UIButton {

  // MARK: Properties

  static var defaultSize: CGSize {
    return CGSize(width: 75, height: 35)
  }

  var color: UIColor? = nil {
    didSet {
      layer.borderColor = color?.CGColor
    }
  }

  // MARK: Initializers

  convenience init() {
    self.init(frame: CGRectZero)

    clipsToBounds = true

    layer.borderWidth = 2

    titleLabel?.textAlignment = .Center
    titleLabel?.font = UIFont.SnowballFont.mediumFont.fontWithSize(14)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: UIView

  override func drawRect(rect: CGRect) {
    super.drawRect(rect)

    layer.cornerRadius = bounds.height / 2
  }

  // MARK: Internal

  func configureForUser(user: User) {
    color = user.color

    setFollowing(user.following, animated: false)
  }

  func setFollowing(following: Bool, animated: Bool) {
    if following {
      setTitleColor(color, forState: .Normal)
      backgroundColor = nil
      setTitle(NSLocalizedString("unfollow", comment: ""), forState: .Normal)
    } else {
      setTitleColor(UIColor.whiteColor(), forState: .Normal)
      backgroundColor = color
      setTitle(NSLocalizedString("follow", comment: ""), forState: .Normal)
    }
  }
}