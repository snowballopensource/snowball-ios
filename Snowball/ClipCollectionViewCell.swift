//
//  ClipCollectionViewCell.swift
//  Snowball
//
//  Created by James Martinez on 7/30/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import Haneke
import UIKit

enum ClipCollectionViewCellState {
  case Default
}

class ClipCollectionViewCell: UICollectionViewCell {

  // MARK: - Properties

  class var size: CGSize {
    let screenHeight = UIScreen.mainScreen().bounds.height
    let screenWidth = UIScreen.mainScreen().bounds.width
    let cellHeight = screenHeight - screenWidth
    var cellWidth = screenWidth / 2.5
    return CGSizeMake(cellWidth, cellHeight)
  }

  private let clipThumbnailImageView = UIImageView()
  private let userAvatarImageView = UserAvatarImageView()

  private let usernameLabel: UILabel = {
    let label = UILabel()
    var fontSize: CGFloat = 17
    if isIphone4S {
      fontSize = 15
    }
    label.font = UIFont(name: UIFont.SnowballFont.bold, size: fontSize)
    label.textAlignment = NSTextAlignment.Center
    return label
    }()

  private let clipTimeLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: UIFont.SnowballFont.regular, size: 12)
    label.textAlignment = NSTextAlignment.Center
    label.textColor = UIColor.SnowballColor.grayColor
    return label
    }()

  private let likeButton: UIButton = {
    let button = UIButton()
    let heartImage = UIImage(named: "heart")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    let heartFilledImage = UIImage(named: "heart-filled")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    button.setImage(heartImage, forState: UIControlState.Normal)
    button.setImage(heartFilledImage, forState: UIControlState.Selected)
    return button
    }()

  // MARK: - Initializers

  override init(frame: CGRect) {
    super.init(frame: frame)

    setupSubviews()

    likeButton.addTarget(self, action: "likeButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - UICollectionViewCell

  override func prepareForReuse() {
    super.prepareForReuse()

    clipThumbnailImageView.image = nil
    userAvatarImageView.image = nil
  }

  // MARK: - Internal

  func configureForClip(clip: Clip, state: ClipCollectionViewCellState) {
    let userColor = clip.user?.color as? UIColor ?? UIColor.SnowballColor.blueColor

    if let thumbnailURL = clip.thumbnailURL {
      clipThumbnailImageView.hnk_setImageFromURL(thumbnailURL, format: Format<UIImage>(name: "original"))
    }

    if let user = clip.user {
      userAvatarImageView.configureForUser(user)
    }

    usernameLabel.text = clip.user?.username
    usernameLabel.textColor = userColor

    clipTimeLabel.text = clip.createdAt?.shortTimeSinceString()

    likeButton.selected = clip.liked
    likeButton.tintColor = userColor
    likeButton.hidden = false
    if clip.user == User.currentUser {
      likeButton.hidden = true
    }
  }

  // MARK: - Private

  private func setupSubviews() {
    contentView.addSubview(clipThumbnailImageView)
    layout(clipThumbnailImageView) { (clipThumbnailImageView) in
      clipThumbnailImageView.leading == clipThumbnailImageView.superview!.leading
      clipThumbnailImageView.top == clipThumbnailImageView.superview!.top
      clipThumbnailImageView.trailing == clipThumbnailImageView.superview!.trailing
      clipThumbnailImageView.height == clipThumbnailImageView.width
    }

    contentView.addSubview(userAvatarImageView)
    layout(userAvatarImageView, clipThumbnailImageView) { (userAvatarImageView, clipThumbnailImageView) in
      var width: Float = 40
      if isIphone4S { width = 30 }
      userAvatarImageView.centerX == userAvatarImageView.superview!.centerX
      userAvatarImageView.centerY == clipThumbnailImageView.bottom
      userAvatarImageView.width == width
      userAvatarImageView.height == userAvatarImageView.width
    }

    contentView.addSubview(usernameLabel)
    layout(usernameLabel, userAvatarImageView) { (usernameLabel, userAvatarImageView) in
      usernameLabel.centerX == usernameLabel.superview!.centerX
      usernameLabel.top == userAvatarImageView.bottom + 5
    }

    contentView.addSubview(clipTimeLabel)
    layout(clipTimeLabel, usernameLabel) { (clipTimeLabel, usernameLabel) in
      clipTimeLabel.left == clipTimeLabel.superview!.left
      clipTimeLabel.top == usernameLabel.bottom + 2
      clipTimeLabel.right == clipTimeLabel.superview!.right
      if isIphone4S {
        clipTimeLabel.height == 0
      }
    }

    contentView.addSubview(likeButton)
    layout(likeButton, clipTimeLabel) { (likeButton, clipTimeLabel) in
      likeButton.centerX == likeButton.superview!.centerX
      likeButton.top == clipTimeLabel.bottom + 2
      if isIphone4S {
        likeButton.width == 23
      } else {
        likeButton.width == 44
      }
      likeButton.height == likeButton.width
    }
  }
}