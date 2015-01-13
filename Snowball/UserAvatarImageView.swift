//
//  UserAvatarImageView.swift
//  Snowball
//
//  Created by James Martinez on 12/5/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

class UserAvatarImageView: UIView {
  let imageView = UIImageView()
  let initialsLabel = UILabel()

  // MARK: - UIView

  override init(frame: CGRect) {
    super.init(frame: frame)
    clipsToBounds = true
    initialsLabel.textColor = UIColor.blackColor()
    initialsLabel.textAlignment = NSTextAlignment.Center
    addSubview(initialsLabel)
    addSubview(imageView)
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  convenience override init() {
    self.init(frame: CGRectZero)
  }

  override func layoutSubviews() {
    layer.cornerRadius = frame.size.width/2
    initialsLabel.font = UIFont(name: UIFont.SnowballFont.regular, size: frame.size.height / 3)

    initialsLabel.frame = bounds
    imageView.frame = bounds
  }

  // MARK: - Configuration
  // TODO: create method for setting user or something
}