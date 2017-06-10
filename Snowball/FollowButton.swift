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
      layer.borderColor = color?.cgColor
    }
  }

  // MARK: Initializers

  convenience init() {
    self.init(frame: CGRect.zero)

    clipsToBounds = true

    layer.borderWidth = 2

    titleLabel?.textAlignment = .center
    titleLabel?.font = UIFont.SnowballFont.mediumFont.withSize(14)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: UIView

  override func draw(_ rect: CGRect) {
    super.draw(rect)

    layer.cornerRadius = bounds.height / 2
  }

  // MARK: Internal

  func configureForUser(_ user: User) {
    color = user.color

    setFollowing(user.following, animated: false)
  }

  func setFollowing(_ following: Bool, animated: Bool) {
    if following {
      setTitleColor(color, for: UIControlState())
      backgroundColor = nil
      setTitle(NSLocalizedString("unfollow", comment: ""), for: UIControlState())
    } else {
      setTitleColor(UIColor.white, for: UIControlState())
      backgroundColor = color
      setTitle(NSLocalizedString("follow", comment: ""), for: UIControlState())
    }
  }
}
