//
//  UserAvatarImageView.swift
//  Snowball
//
//  Created by James Martinez on 12/5/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

class UserAvatarImageView: UIView {

  // MARK: - Properties

  private let imageView = UIImageView()

  // MARK: - UIView

  override init(frame: CGRect) {
    super.init(frame: frame)
    clipsToBounds = true
    backgroundColor = UIColor.SnowballColor.greenColor
    addSubview(imageView)
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  convenience override init() {
    self.init(frame: CGRectZero)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    layer.cornerRadius = frame.size.width/2
    imageView.frame = bounds
  }

  // MARK: - Internal

  func configureForUser(user: User) {
    backgroundColor = user.color as? UIColor ?? UIColor.SnowballColor.greenColor
  }
}