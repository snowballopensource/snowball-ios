//
//  UserImageView.swift
//  Snowball
//
//  Created by James Martinez on 8/10/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import UIKit

class UserImageView: UIImageView {

  // MARK: Initializers

  init() {
    super.init(frame: CGRectZero)
    clipsToBounds = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: UIView

  override func layoutSubviews() {
    super.layoutSubviews()
    layer.cornerRadius = bounds.width / 2
  }

  // MARK: Internal

  func configureForUser(user: User) {
    backgroundColor = user.color
    setImageFromRemoteURL(user.avatarURL)
  }
}
