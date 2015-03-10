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

class ClipCollectionViewCell: UICollectionViewCell {

  // MARK: - Properties

  class var size: CGSize {
    let screenHeight = UIScreen.mainScreen().bounds.height
    let screenWidth = UIScreen.mainScreen().bounds.width
    let cellHeight = screenHeight - screenWidth
    var cellWidth: CGFloat = 140
    if isIphone4S {
      cellWidth = 90
    }
    return CGSizeMake(cellWidth, cellHeight)
  }

  private let clipThumbnailImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = UIViewContentMode.ScaleAspectFill
    return imageView
  }()

  private let clipThumbnailLoadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)

  private let addClipImageView = UIImageView(image: UIImage(named: "add-clip"))

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
    label.textColor = UIColor(red: 210/255.0, green: 210/255.0, blue: 210/255.0, alpha: 1.0)
    return label
  }()

  private let dimView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.whiteColor()
    view.alpha = 0.6
    view.hidden = true
    return view
  }()

  // MARK: - Initializers

  override init(frame: CGRect) {
    super.init(frame: frame)

    contentView.addSubview(clipThumbnailImageView)
    layout(clipThumbnailImageView) { (clipThumbnailImageView) in
      clipThumbnailImageView.left == clipThumbnailImageView.superview!.left
      clipThumbnailImageView.top == clipThumbnailImageView.superview!.top
      clipThumbnailImageView.right == clipThumbnailImageView.superview!.right
      clipThumbnailImageView.height == clipThumbnailImageView.superview!.width
    }

    clipThumbnailImageView.addSubview(clipThumbnailLoadingIndicator)
    layout(clipThumbnailLoadingIndicator) { (clipThumbnailLoadingIndicator) in
      clipThumbnailLoadingIndicator.left == clipThumbnailLoadingIndicator.superview!.left
      clipThumbnailLoadingIndicator.top == clipThumbnailLoadingIndicator.superview!.top
      clipThumbnailLoadingIndicator.right == clipThumbnailLoadingIndicator.superview!.right
      clipThumbnailLoadingIndicator.height == clipThumbnailLoadingIndicator.superview!.width
    }

    clipThumbnailImageView.addSubview(addClipImageView)

    var avatarDiameter: CGFloat = 40
    if isIphone4S {
      avatarDiameter = 30
    }

    contentView.addSubview(userAvatarImageView)
    layout(userAvatarImageView, clipThumbnailImageView) { (userAvatarImageView, clipThumbnailImageView) in
      userAvatarImageView.centerX == userAvatarImageView.superview!.centerX
      userAvatarImageView.top == clipThumbnailImageView.bottom + 10
      userAvatarImageView.width == avatarDiameter
      userAvatarImageView.height == userAvatarImageView.width
    }

    contentView.addSubview(usernameLabel)
    layout(usernameLabel, userAvatarImageView) { (usernameLabel, userAvatarImageView) in
      usernameLabel.left == usernameLabel.superview!.left
      usernameLabel.top == userAvatarImageView.bottom + 5
      usernameLabel.right == usernameLabel.superview!.right
    }

    contentView.addSubview(clipTimeLabel)
    layout(clipTimeLabel, usernameLabel) { (clipTimeLabel, usernameLabel) in
      clipTimeLabel.left == clipTimeLabel.superview!.left
      clipTimeLabel.top == usernameLabel.bottom + 2
      clipTimeLabel.right == clipTimeLabel.superview!.right
    }

    contentView.addSubview(dimView)
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - UIView

  override func layoutSubviews() {
    super.layoutSubviews()

    addClipImageView.frame = clipThumbnailImageView.bounds

    dimView.frame = contentView.bounds
  }

  // MARK: - Internal

  func configureForClip(clip: Clip) {
    usernameLabel.text = clip.user?.username
    let userColor = clip.user?.color as? UIColor ?? UIColor.SnowballColor.greenColor
    if let user = clip.user {
      userAvatarImageView.configureForUser(user)
    }
    usernameLabel.textColor = userColor
    clipTimeLabel.text = clip.createdAt?.shortTimeSinceString()

    clipThumbnailImageView.image = UIImage()
    if let thumbnailURL = clip.thumbnailURL {
      if thumbnailURL.scheme == "file" {
        let imageData = NSData(contentsOfURL: thumbnailURL)!
        let image = UIImage(data: imageData)
        clipThumbnailImageView.image = image
      } else {
        clipThumbnailLoadingIndicator.startAnimating()
        clipThumbnailImageView.hnk_setImageFromURL(thumbnailURL, format: Format<UIImage>(name: "original"), failure: { _ in
          self.clipThumbnailLoadingIndicator.stopAnimating()
        }, success: { (image) in
          self.clipThumbnailImageView.image = image
          self.clipThumbnailLoadingIndicator.stopAnimating()
        })
      }
    }
    setInPlayState(false, isCurrentPlayingClip: false, animated: false)
    if clip.state == ClipState.Pending {
      addClipImageView.hidden = false
    } else {
      addClipImageView.hidden = true
    }
  }

  func setInPlayState(inPlayState: Bool, isCurrentPlayingClip: Bool, animated: Bool = true) {
    scaleClipThumbnail(inPlayState, animated: animated)
    let shouldDimContentView = (inPlayState && !isCurrentPlayingClip)
    dimContentView(shouldDimContentView)
  }

  // MARK: - Private

  private func dimContentView(dim: Bool) {
    dimView.hidden = !dim
  }

  private func scaleClipThumbnail(down: Bool, animated: Bool) {
    if animated {
      UIView.animateWithDuration(0.4) {
        self.scaleClipThumbnail(down, animated: false)
      }
    } else {
      if down {
        clipThumbnailImageView.transform = CGAffineTransformMakeScale(0.85, 0.85)
      } else {
        clipThumbnailImageView.transform = CGAffineTransformMakeScale(1.0, 1.0)
      }
    }
  }
}
