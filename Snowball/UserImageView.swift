//
//  UserImageView.swift
//  Snowball
//
//  Created by James Martinez on 10/5/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class UserImageView: UIView {
  let imageView = UIImageView()
  let initialsLabel = UILabel()

  override init(frame: CGRect) {
    super.init(frame: frame)
    clipsToBounds = true
    initialsLabel.textColor = UIColor.whiteColor()
    initialsLabel.textAlignment = NSTextAlignment.Center
    addFullViewSubview(initialsLabel)
    addFullViewSubview(imageView)
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  convenience override init() {
    self.init(frame: CGRectZero)
  }

  override func layoutSubviews() {
    layer.cornerRadius = frame.size.width/2
    initialsLabel.font = initialsLabel.font.fontWithSize(frame.size.height/2.5)
  }

  func setUser(user: User) {
    backgroundColor = user.color
    initialsLabel.text = user.initials
    imageView.image = nil
    if countElements(user.avatarURL) > 0 {
      imageView.setImageFromURL(NSURL(string: user.avatarURL), placeholder: nil, completionHandler: nil)
    }
  }
}