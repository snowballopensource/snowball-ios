//
//  ClipCollectionViewCell.swift
//  Snowball
//
//  Created by James Martinez on 12/4/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Cartography
import Haneke
import UIKit

protocol ClipCollectionViewCellDelegate: class {
  func playClipButtonTappedInCell(cell: ClipCollectionViewCell)
}

class ClipCollectionViewCell: UICollectionViewCell {
  var delegate: ClipCollectionViewCellDelegate?
  private let clipThumbnailImageView = UIImageView()
  private let userAvatarImageView = UserAvatarImageView()
  private let usernameLabel = UILabel()
  private let clipTimeLabel = UILabel()
  let playButton = UIButton()

  override init(frame: CGRect) {
    super.init(frame: frame)
    clipThumbnailImageView.contentMode = UIViewContentMode.ScaleAspectFill
    clipThumbnailImageView.backgroundColor = UIColor.blackColor()
    contentView.addSubview(clipThumbnailImageView)
    contentView.addSubview(userAvatarImageView)
    usernameLabel.font = UIFont(name: UIFont.SnowballFont.bold, size: 18)
    usernameLabel.textAlignment = NSTextAlignment.Center
    contentView.addSubview(usernameLabel)
    clipTimeLabel.font = UIFont(name: "Helvetica-Bold", size: 16)
    clipTimeLabel.textAlignment = NSTextAlignment.Center
    clipTimeLabel.textColor = UIColor(red: 210/255.0, green: 210/255.0, blue: 210/255.0, alpha: 1.0)
    contentView.addSubview(clipTimeLabel)
    playButton.setImage(UIImage(named: "play"), forState: UIControlState.Normal)
    playButton.addTarget(self, action: "playClip", forControlEvents: UIControlEvents.TouchUpInside)
    contentView.addSubview(playButton)
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

    layout(usernameLabel, userAvatarImageView) { (usernameLabel, userAvatarImageView) in
      usernameLabel.left == usernameLabel.superview!.left
      usernameLabel.top == userAvatarImageView.bottom + 5
      usernameLabel.right == usernameLabel.superview!.right
    }

    layout(clipTimeLabel, usernameLabel) { (clipTimeLabel, usernameLabel) in
      clipTimeLabel.left == clipTimeLabel.superview!.left
      clipTimeLabel.top == usernameLabel.bottom + 2
      clipTimeLabel.right == clipTimeLabel.superview!.right
    }

    playButton.frame = clipThumbnailImageView.frame
  }

  // MARK: - UICollectionReuseableView+Required

  override class var size: CGSize {
    let screenHeight = UIScreen.mainScreen().bounds.height
    let screenWidth = UIScreen.mainScreen().bounds.width
    let cellHeight = screenHeight - screenWidth
    return CGSizeMake(140.0, cellHeight)
  }

  func configureForClip(clip: NewClip) {
    usernameLabel.text = clip.user?.username
    let userColor = UIColor.SnowballColor.greenColor
    userAvatarImageView.backgroundColor = userColor
    usernameLabel.textColor = userColor
    clipTimeLabel.text = clip.createdAt?.shortTimeSinceString()

    clipThumbnailImageView.image = UIImage()
    if let thumbnailURL = clip.thumbnailURL {
      if thumbnailURL.scheme == "file" {
        let imageData = NSData(contentsOfURL: thumbnailURL)!
        let image = UIImage(data: imageData)
        clipThumbnailImageView.image = image
      } else {
        clipThumbnailImageView.hnk_setImageFromURL(thumbnailURL, format: Format<UIImage>(name: "original"))
      }
    }
    playButton.hidden = false
  }

  // MARK: - Private

  @objc private func playClip() {
    delegate?.playClipButtonTappedInCell(self)
  }
}
