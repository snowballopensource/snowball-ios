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

  var delegate: ClipCollectionViewCellDelegate?

  private let clipThumbnailImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = UIViewContentMode.ScaleAspectFill
    return imageView
  }()

  private let clipThumbnailLoadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)

  private let addClipImageView = UIImageView(image: UIImage(named: "add-clip"))

  private let showOptionsGestureRecognizer: UISwipeGestureRecognizer = {
    let swipeGestureRecognizer = UISwipeGestureRecognizer()
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Down
    return swipeGestureRecognizer
    }()

  private let hideOptionsGestureRecognizer: UISwipeGestureRecognizer = {
    let swipeGestureRecognizer = UISwipeGestureRecognizer()
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Up
    return swipeGestureRecognizer
    }()

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

  private let optionsView = ClipOptionsView()

  private let optionsViewOverlay: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.blackColor()
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
      clipThumbnailLoadingIndicator.height == clipThumbnailLoadingIndicator.superview!.height
    }

    clipThumbnailImageView.addSubview(addClipImageView)

    showOptionsGestureRecognizer.addTarget(self, action: "showOptionsGestureRecognizerSwiped")
    addGestureRecognizer(showOptionsGestureRecognizer)

    hideOptionsGestureRecognizer.addTarget(self, action: "hideOptionsGestureRecognizerSwiped")
    addGestureRecognizer(hideOptionsGestureRecognizer)

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

    contentView.addSubview(optionsView)
    optionsView.delegate = self

    clipThumbnailImageView.addSubview(optionsViewOverlay)
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - UIView

  override func layoutSubviews() {
    super.layoutSubviews()

    addClipImageView.frame = clipThumbnailImageView.bounds
    optionsView.frame = clipThumbnailImageView.bounds
    optionsViewOverlay.frame = clipThumbnailImageView.bounds
    hideOptionsViewAnimated(false)
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

    hideOptionsViewAnimated(false)
    optionsView.configureForUser(clip.user)
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

  private func hideOptionsViewAnimated(animated: Bool) {
    if animated {
      UIView.animateWithDuration(0.2) {
        self.hideOptionsViewAnimated(false)
      }
    } else {
      optionsViewOverlay.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0)
      let frame = self.optionsView.frame
      let newOriginY: CGFloat = -frame.size.height
      if frame.origin.y == newOriginY { return }
      let newFrame = CGRectMake(frame.origin.x, newOriginY, frame.size.width, frame.size.height)
      self.optionsView.frame = newFrame
    }
  }

  private func showOptionsViewAnimated(animated: Bool) {
    if animated {
      UIView.animateWithDuration(0.2) {
        self.showOptionsViewAnimated(false)
      }
    } else {
      optionsViewOverlay.backgroundColor = optionsViewOverlay.backgroundColor?.colorWithAlphaComponent(0.5)
      let frame = self.optionsView.frame
      let newOriginY: CGFloat = 0
      if frame.origin.y == newOriginY { return }
      let newFrame = CGRectMake(frame.origin.x, newOriginY, frame.size.width, frame.size.height)
      self.optionsView.frame = newFrame
    }
  }

  @objc private func showOptionsGestureRecognizerSwiped() {
    showOptionsViewAnimated(true)
  }

  @objc private func hideOptionsGestureRecognizerSwiped() {
    hideOptionsViewAnimated(true)
  }
}

// MARK: -

protocol ClipCollectionViewCellDelegate {
  func userDidDeleteClipForCell(cell: ClipCollectionViewCell)
  func userDidFlagClipForCell(cell: ClipCollectionViewCell)
}

// MARK: -

extension ClipCollectionViewCell: ClipOptionsViewDelegate {

  // MARK: - ClipOptionsViewDelegate

  func userDidSelectFlagClipOption() {
    delegate?.userDidFlagClipForCell(self)
  }

  func userDidSelectDeleteClipOption() {
    delegate?.userDidDeleteClipForCell(self)
  }
}

// MARK: -

class ClipOptionsView: UIView {

  // MARK: - Properties

  private let flagButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(named: "clip-flag"), forState: UIControlState.Normal)
    return button
  }()

  private let deleteButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(named: "clip-delete"), forState: UIControlState.Normal)
    return button
  }()

  var delegate: ClipOptionsViewDelegate?

  // MARK: - Initializers

  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(flagButton)
    flagButton.addTarget(self, action: "flagButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    addSubview(deleteButton)
    deleteButton.addTarget(self, action: "deleteButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  convenience override init() {
    self.init(frame: CGRectZero)
  }

  // MARK: - UIView

  override func layoutSubviews() {
    super.layoutSubviews()
    flagButton.frame = bounds
    deleteButton.frame = bounds
  }

  // MARK: - Internal

  func configureForUser(user: User?) {
    flagButton.hidden = true
    deleteButton.hidden = true
    if let user = user {
      if let currentUser = User.currentUser {
        if user.id == currentUser.id {
          deleteButton.hidden = false
        } else {
          flagButton.hidden = false
        }
      }
    }
  }

  // MARK: - Private

  @objc private func flagButtonTapped() {
    delegate?.userDidSelectFlagClipOption()
  }

  @objc private func deleteButtonTapped() {
    delegate?.userDidSelectDeleteClipOption()
  }
}

// MARK: -

protocol ClipOptionsViewDelegate {
  func userDidSelectFlagClipOption()
  func userDidSelectDeleteClipOption()
}