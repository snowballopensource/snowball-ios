//
//  ClipCollectionViewCell.swift
//  Snowball
//
//  Created by James Martinez on 12/4/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class ClipCollectionViewCell: UICollectionViewCell {
  let clipThumbnailImageView = UIImageView()
  let userAvatarImageView = UserAvatarImageView()
  let userNameLabel = UILabel()
  let clipTimeLabel = UILabel()
  let playButton = UIButton()
  let pauseButton = UIButton()

  override init(frame: CGRect) {
    super.init(frame: frame)
    clipThumbnailImageView.backgroundColor = UIColor.blackColor()
    contentView.addSubview(clipThumbnailImageView)
    contentView.addSubview(userAvatarImageView)
    userNameLabel.font = UIFont(name: "Karla-Bold", size: 18)
    userNameLabel.textAlignment = NSTextAlignment.Center
    contentView.addSubview(userNameLabel)
    clipTimeLabel.font = UIFont(name: "Helvetica-Bold", size: 16)
    clipTimeLabel.textAlignment = NSTextAlignment.Center
    clipTimeLabel.textColor = UIColor(red: 210/255.0, green: 210/255.0, blue: 210/255.0, alpha: 1.0)
    contentView.addSubview(clipTimeLabel)
    playButton.setImage(UIImage(named: "play"), forState: UIControlState.Normal)
    contentView.addSubview(playButton)
    pauseButton.setImage(UIImage(named: "pause"), forState: UIControlState.Normal)
    contentView.addSubview(pauseButton)
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - UIView

  override func layoutSubviews() {
    super.layoutSubviews()

    layout(clipThumbnailImageView) { (clipThumbnailImageView) in
      clipThumbnailImageView.left == clipThumbnailImageView.superview!.left
      clipThumbnailImageView.top == clipThumbnailImageView.superview!.top
      clipThumbnailImageView.right == clipThumbnailImageView.superview!.right
      clipThumbnailImageView.height == clipThumbnailImageView.superview!.width
    }

    layout(userAvatarImageView, clipThumbnailImageView) { (userAvatarImageView, clipThumbnailImageView) in
      userAvatarImageView.centerX == userAvatarImageView.superview!.centerX
      userAvatarImageView.top == clipThumbnailImageView.bottom + 10
      userAvatarImageView.width == 40
      userAvatarImageView.height == userAvatarImageView.width
    }

    layout(userNameLabel, userAvatarImageView) { (userNameLabel, userAvatarImageView) in
      userNameLabel.left == userNameLabel.superview!.left
      userNameLabel.top == userAvatarImageView.bottom + 5
      userNameLabel.right == userNameLabel.superview!.right
    }

    layout(clipTimeLabel, userNameLabel) { (clipTimeLabel, userNameLabel) in
      clipTimeLabel.left == clipTimeLabel.superview!.left
      clipTimeLabel.top == userNameLabel.bottom + 2
      clipTimeLabel.right == clipTimeLabel.superview!.right
    }

    playButton.frame = clipThumbnailImageView.frame

    pauseButton.frame = clipThumbnailImageView.frame
  }

  // MARK: - UICollectionReuseableView+Required

  override class func size() -> CGSize {
    let screenHeight = UIScreen.mainScreen().bounds.height
    let screenWidth = UIScreen.mainScreen().bounds.width
    let cellHeight = screenHeight - screenWidth
    return CGSizeMake(140.0, cellHeight)
  }

  override func configureForObject(object: AnyObject) {
    userNameLabel.text = "Name"
    // TODO: replace with user color
    let userColor = UIColor.SnowballColor.randomColor()
    userAvatarImageView.backgroundColor = userColor
    userNameLabel.textColor = userColor
    clipTimeLabel.text = "1h"

    playButton.hidden = true
    pauseButton.hidden = true
  }
}
