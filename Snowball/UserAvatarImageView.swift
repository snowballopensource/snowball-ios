//
//  UserAvatarImageView.swift
//  Snowball
//
//  Created by James Martinez on 12/5/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Haneke
import UIKit

class UserAvatarImageView: UIView {

  // MARK: - Properties

  let imageView = UIImageView()

  // MARK: - UIView

  override init(frame: CGRect) {
    super.init(frame: frame)
    clipsToBounds = true
    backgroundColor = UIColor.SnowballColor.blueColor
    addSubview(imageView)
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    layer.cornerRadius = frame.size.width/2
    imageView.frame = bounds
  }

  // MARK: - Internal

  func configureForUser(user: User) {
    backgroundColor = user.color as? UIColor ?? UIColor.SnowballColor.blueColor
    imageView.image = UIImage(named: "face")
    if let imageURLString = user.avatarURL {
      if let imageURL = NSURL(string: imageURLString) {
        imageView.hnk_setImageFromURL(imageURL, format: Format<UIImage>(name: "original"))
      }
    }
  }
}