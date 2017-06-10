//
//  UserAvatarImageView.swift
//  Snowball
//
//  Created by James Martinez on 1/18/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Foundation
import UIKit

class UserAvatarImageView: UIImageView {

  // MARK: Initializers

  init() {
    super.init(frame: CGRect.zero)
    clipsToBounds = true
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: UIView

  override func layoutSubviews() {
    super.layoutSubviews()
    layer.cornerRadius = bounds.width / 2
  }

  // MARK: Internal

  func setUser(_ user: User) {
    backgroundColor = user.color
    image = UIImage(named: "user-avatar-default")
    if let URLString = user.avatarURL, let URL = URL(string: URLString) {
      setImageFromURL(URL)
    }
  }
}
