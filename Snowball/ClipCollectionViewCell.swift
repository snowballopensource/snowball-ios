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

  // MARK: - Initializers

  override init(frame: CGRect) {
    super.init(frame: frame)

    setupSubviews()
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
    backgroundColor = clip.user?.color as? UIColor ?? UIColor.SnowballColor.blueColor

    if let thumbnailURL = clip.thumbnailURL {
      clipThumbnailImageView.hnk_setImageFromURL(thumbnailURL, format: Format<UIImage>(name: "original"))
    }
    if let user = clip.user {
      userAvatarImageView.configureForUser(user)
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
  }
}