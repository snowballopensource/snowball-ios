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
  let usernameLabel: UILabel = {
    let label = UILabel()
    label.font = label.font.fontWithSize(14)
    label.textAlignment = .Center
    return label
  }()
  let clipCreatedAtLabel: UILabel = {
    let label = UILabel()
    label.font = label.font.fontWithSize(12)
    label.textAlignment = .Center
    label.textColor = UIColor.SnowballColor.lightGrayColor
    return label
  }()
  let likeButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(named: "cell-clip-heart"), forState: .Normal)
    button.setImage(UIImage(named: "cell-clip-heart-filled"), forState: .Selected)
    button.setImage(UIImage(named: "cell-clip-heart-filled"), forState: .Highlighted)
    return button
  }()

  private(set) var state: ClipCollectionViewCellState = .Default

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
    userImageView.widthAnchor.constraintEqualToConstant(40).active = true
    userImageView.heightAnchor.constraintEqualToAnchor(userImageView.widthAnchor).active = true

    addSubview(usernameLabel)
    usernameLabel.translatesAutoresizingMaskIntoConstraints = false
    usernameLabel.leftAnchor.constraintEqualToAnchor(leftAnchor).active = true
    usernameLabel.topAnchor.constraintEqualToAnchor(userImageView.bottomAnchor, constant: 7).active = true
    usernameLabel.rightAnchor.constraintEqualToAnchor(rightAnchor).active = true

    addSubview(clipCreatedAtLabel)
    clipCreatedAtLabel.translatesAutoresizingMaskIntoConstraints = false
    clipCreatedAtLabel.leftAnchor.constraintEqualToAnchor(leftAnchor).active = true
    clipCreatedAtLabel.topAnchor.constraintEqualToAnchor(usernameLabel.bottomAnchor, constant: 4).active = true
    clipCreatedAtLabel.rightAnchor.constraintEqualToAnchor(rightAnchor).active = true

    addSubview(likeButton)
    likeButton.translatesAutoresizingMaskIntoConstraints = false
    likeButton.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
    likeButton.topAnchor.constraintEqualToAnchor(clipCreatedAtLabel.bottomAnchor, constant: 18).active = true
    likeButton.widthAnchor.constraintEqualToConstant(35).active = true
    likeButton.heightAnchor.constraintEqualToConstant(30).active = true
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  func configureForClip(clip: Clip, state: ClipCollectionViewCellState = .Default) {
    setState(state, animated: false)

    imageView.setImageFromRemoteURL(clip.imageURL)
    userImageView.setImageFromRemoteURL(clip.user.avatarURL)

    usernameLabel.text = clip.user.username
    usernameLabel.textColor = clip.user.color

    clipCreatedAtLabel.text = clip.createdAt?.shortTimeSinceString() ?? NSLocalizedString("Now", comment: "")
  }

  func setState(state: ClipCollectionViewCellState, animated: Bool) {
    if animated {
      UIView.animateWithDuration(0.4) {
        self.setState(state, animated: false)
      }
      return
    }

    if state == .PlayingActive || state == .PlayingInactive {
      imageView.transform = CGAffineTransformMakeScale(0.8, 0.8)
    } else {
      imageView.transform = CGAffineTransformMakeScale(1, 1)
    }

    if state == .PlayingInactive {
      imageView.alpha = 0.5
      userImageView.alpha = 0
    } else {
      imageView.alpha = 1
      userImageView.alpha = 1
    }
  }
}

// MARK: - ClipCollectionViewCellState
enum ClipCollectionViewCellState {
  case Default, PlayingActive, PlayingInactive
}
