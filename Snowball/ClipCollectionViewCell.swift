//
//  ClipCollectionViewCell.swift
//  Snowball
//
//  Created by James Martinez on 8/8/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import UIKit

class ClipCollectionViewCell: UICollectionViewCell {

  // MARK: Properties

  class var defaultSize: CGSize {
    let screenHeight = UIScreen.mainScreen().bounds.height
    let screenWidth = UIScreen.mainScreen().bounds.width
    let cellHeight = screenHeight - screenWidth
    let cellsPerScreen: CGFloat = 2.5
    let cellWidth = screenWidth / cellsPerScreen
    return CGSizeMake(cellWidth, cellHeight)
  }

  let imageView = UIImageView()
  let userImageView = UserImageView()

  // MARK: Initializers

  override init(frame: CGRect) {
    super.init(frame: CGRectZero)

    addSubview(imageView)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.leftAnchor.constraintEqualToAnchor(leftAnchor).active = true
    imageView.topAnchor.constraintEqualToAnchor(topAnchor).active = true
    imageView.rightAnchor.constraintEqualToAnchor(rightAnchor).active = true
    imageView.heightAnchor.constraintEqualToAnchor(widthAnchor).active = true

    addSubview(userImageView)
    userImageView.translatesAutoresizingMaskIntoConstraints = false
    userImageView.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
    userImageView.centerYAnchor.constraintEqualToAnchor(imageView.bottomAnchor).active = true
    userImageView.widthAnchor.constraintEqualToAnchor(widthAnchor, multiplier: 1/3).active = true
    userImageView.heightAnchor.constraintEqualToAnchor(userImageView.widthAnchor).active = true
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  func configureForClip(clip: Clip) {
    imageView.setImageFromRemoteURL(clip.imageURL)
    userImageView.setImageFromRemoteURL(clip.user.avatarURL)
  }
}
