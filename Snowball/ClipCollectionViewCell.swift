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
  let userAvatarImageView = UIImageView()
  let detailLabel = UILabel()

  override init(frame: CGRect) {
    super.init(frame: frame)
    clipThumbnailImageView.backgroundColor = UIColor.blackColor()
    userAvatarImageView.backgroundColor = UIColor.blackColor()
    detailLabel.textAlignment = NSTextAlignment.Center
    detailLabel.font = UIFont(name: "Karla-Bold", size: 18)
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - UIView

  override func layoutSubviews() {
    super.layoutSubviews()

    contentView.addSubview(clipThumbnailImageView)
    layout(clipThumbnailImageView) { (clipThumbnailImageView) in
      clipThumbnailImageView.left == clipThumbnailImageView.superview!.left
      clipThumbnailImageView.top == clipThumbnailImageView.superview!.top
      clipThumbnailImageView.right == clipThumbnailImageView.superview!.right
      clipThumbnailImageView.height == clipThumbnailImageView.superview!.width
    }

    contentView.addSubview(userAvatarImageView)
    layout(userAvatarImageView, clipThumbnailImageView) { (userAvatarImageView, clipThumbnailImageView) in
      userAvatarImageView.centerX == userAvatarImageView.superview!.centerX
      userAvatarImageView.top == clipThumbnailImageView.bottom + 10
      userAvatarImageView.width == 40
      userAvatarImageView.height == userAvatarImageView.width
    }

    contentView.addSubview(detailLabel)
    layout(detailLabel, userAvatarImageView) { (detailLabel, userAvatarImageView) in
      detailLabel.left == detailLabel.superview!.left
      detailLabel.top == userAvatarImageView.bottom + 5
      detailLabel.right == detailLabel.superview!.right
      // detailLabel.height == detailLabel.superview!.width
    }
  }

  // MARK: - UICollectionReuseableView+Required

  override class func size() -> CGSize {
    let screenHeight = UIScreen.mainScreen().bounds.height
    let screenWidth = UIScreen.mainScreen().bounds.width
    let cellHeight = screenHeight - screenWidth
    return CGSizeMake(140.0, cellHeight)
  }

  override func configureForObject(object: AnyObject {
    detailLabel.text = "Name, 1h"
  }
}
