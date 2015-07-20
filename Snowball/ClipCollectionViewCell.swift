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
    var cellWidth: CGFloat = screenWidth / 2.5
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

  private let addClipImageView: UIImageView = {
    let imageView = UIImageView(image: UIImage(named: "add-clip"))
    imageView.backgroundColor = User.currentUser?.color as? UIColor ?? UIColor.SnowballColor.blueColor
    imageView.contentMode = UIViewContentMode.Center
    return imageView
  }()

  private let playClipImageView: UIImageView = {
    let imageView = UIImageView(image: UIImage(named: "play"))
    imageView.contentMode = UIViewContentMode.Center
    return imageView
    }()

  private let pauseClipImageView: UIImageView = {
    let imageView = UIImageView(image: UIImage(named: "pause"))
    imageView.contentMode = UIViewContentMode.Center
    return imageView
    }()

  private let showOptionsGestureRecognizer: UISwipeGestureRecognizer = {
    let swipeGestureRecognizer = UISwipeGestureRecognizer()
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Down
    return swipeGestureRecognizer
    }()

  private let showOptionsLongPressGestureRecognizer = UILongPressGestureRecognizer()

  private let hideOptionsGestureRecognizer: UISwipeGestureRecognizer = {
    let swipeGestureRecognizer = UISwipeGestureRecognizer()
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Up
    return swipeGestureRecognizer
    }()

  private let userAvatarImageView = UserAvatarImageView()
  private var userAvatarImageViewYConstraint: ConstraintGroup!

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

  private let userButton = UIButton()

  private let likeButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(named: "heart"), forState: UIControlState.Normal)
    button.setImage(UIImage(named: "heart-filled"), forState: UIControlState.Selected)
    return button
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

    addClipImageView.tintColor = User.currentUser?.color as? UIColor ?? UIColor.SnowballColor.blueColor
    clipThumbnailImageView.addSubview(addClipImageView)

    clipThumbnailImageView.addSubview(playClipImageView)

    setPauseImageHidden(true, animated: false)
    clipThumbnailImageView.addSubview(pauseClipImageView)

    showOptionsGestureRecognizer.addTarget(self, action: "showOptionsGestureRecognizerSwiped")
    addGestureRecognizer(showOptionsGestureRecognizer)

    showOptionsLongPressGestureRecognizer.addTarget(self, action: "showOptionsGestureRecognizerLongPressed")
    addGestureRecognizer(showOptionsLongPressGestureRecognizer)

    hideOptionsGestureRecognizer.addTarget(self, action: "hideOptionsGestureRecognizerSwiped")
    addGestureRecognizer(hideOptionsGestureRecognizer)

    var avatarDiameter: CGFloat = 40
    if isIphone4S {
      avatarDiameter = 30
    }

    contentView.addSubview(userAvatarImageView)
    setAvatarConstraintForTopOfBounce(false)
    layout(userAvatarImageView) { (userAvatarImageView) in
      userAvatarImageView.centerX == userAvatarImageView.superview!.centerX
      userAvatarImageView.width == avatarDiameter
      userAvatarImageView.height == userAvatarImageView.width
    }

    userButton.addTarget(self, action: "userButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    contentView.addSubview(userButton)
    layout(userButton, userAvatarImageView) { (userButton, userAvatarImageView) in
      userButton.left == userButton.superview!.left
      userButton.top == userAvatarImageView.top
      userButton.right == userButton.superview!.right
      userButton.bottom == userButton.superview!.bottom
    }

    contentView.addSubview(usernameLabel)
    layout(usernameLabel, clipThumbnailImageView) { (usernameLabel, clipThumbnailImageView) in
      usernameLabel.left == usernameLabel.superview!.left
      usernameLabel.top == clipThumbnailImageView.bottom + (avatarDiameter / 2) + 5
      usernameLabel.right == usernameLabel.superview!.right
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

    likeButton.addTarget(self, action: "likeButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    contentView.addSubview(likeButton)
    layout(likeButton, clipTimeLabel) { (likeButton, clipTimeLabel) in
      likeButton.centerX == likeButton.superview!.centerX
      likeButton.top == clipTimeLabel.bottom + 2
      if isIphone4S {
        likeButton.width == 23
        likeButton.height == 23
      } else {
        likeButton.width == 44
        likeButton.height == 44
      }
    }

    clipThumbnailImageView.addSubview(dimView)

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
    playClipImageView.frame = clipThumbnailImageView.bounds
    pauseClipImageView.frame = clipThumbnailImageView.bounds
    optionsView.frame = clipThumbnailImageView.bounds
    optionsViewOverlay.frame = clipThumbnailImageView.bounds
    hideOptionsViewAnimated(false)
    dimView.frame = clipThumbnailImageView.bounds
  }

  // MARK: - Internal

  func configureForClip(clip: Clip, showBookmarkPlayhead: Bool = false) {
    usernameLabel.text = clip.user?.username
    let userColor = clip.user?.color as? UIColor ?? UIColor.SnowballColor.blueColor
    if let user = clip.user {
      userAvatarImageView.configureForUser(user)
    }
    usernameLabel.textColor = userColor
    clipTimeLabel.text = clip.createdAt?.shortTimeSinceString()

    likeButton.selected = clip.liked
    let heartImage = UIImage(named: "heart")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    let heartFilledImage = UIImage(named: "heart-filled")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    likeButton.setImage(heartImage, forState: UIControlState.Normal)
    likeButton.setImage(heartFilledImage, forState: UIControlState.Selected)
    likeButton.tintColor = userColor

    clipThumbnailImageView.image = nil
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

    if clip.state == ClipState.Pending {
      playClipImageView.alpha = 0
    } else {
      playClipImageView.alpha = CGFloat(showBookmarkPlayhead)
    }
    setInPlayState(false, isCurrentPlayingClip: false, animated: false)
    if clip.state == ClipState.Pending {
      addClipImageView.hidden = false
      likeButton.hidden = true
    } else {
      addClipImageView.hidden = true
      likeButton.hidden = false
      if let currentUser = User.currentUser, clipUser = clip.user {
        if clipUser.id == currentUser.id {
          likeButton.hidden = true
        }
      }
    }
    hideOptionsViewAnimated(false)
    optionsView.configureForUser(clip.user)
    if clip.state == ClipState.Uploading {
      setAvatarBouncing(true)
    }
  }

  func setInPlayState(inPlayState: Bool, isCurrentPlayingClip: Bool, animated: Bool = true) {
    scaleClipThumbnail(inPlayState, isCurrentPlayingClip: isCurrentPlayingClip, animated: animated)
    let shouldDimContentView = (inPlayState && !isCurrentPlayingClip)
    dimContentView(shouldDimContentView)
    let shouldShowPauseImage = (inPlayState && isCurrentPlayingClip)
    setPauseImageHidden(!shouldShowPauseImage, animated: animated)
    hideUserInfo(shouldDimContentView, animated: animated)
    if inPlayState {
      playClipImageView.alpha = 0
    }
  }

  func setClipLikedAnimated(#liked: Bool) {
    likeButton.selected = liked
    if liked {
      let originFrame = likeButton.frame
      let heartImage = likeButton.imageForState(UIControlState.Selected)
      let animatingImageView = UIImageView(image: heartImage)
      animatingImageView.tintColor = likeButton.tintColor
      animatingImageView.frame = originFrame
      contentView.addSubview(animatingImageView)
      UIView.animateWithDuration(1.2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
        animatingImageView.frame = CGRect(x: originFrame.origin.x, y: originFrame.origin.y - 180, width: originFrame.size.width, height: originFrame.size.height)
        animatingImageView.alpha = 0
        animatingImageView.transform = CGAffineTransformMakeScale(1.5, 1.5)
      }, completion: { (completed) -> Void in
        animatingImageView.removeFromSuperview()
      })
    }
  }

  func setBookmarkPlayheadHidden(hidden: Bool) {
    UIView.animateWithDuration(0.4) {
      self.playClipImageView.alpha = CGFloat(!hidden)
    }
  }

  func setPauseImageHidden(hidden: Bool, animated: Bool) {
    if animated {
      UIView.animateWithDuration(0.4) {
        self.setPauseImageHidden(hidden, animated: false)
      }
    } else {
      self.pauseClipImageView.alpha = CGFloat(!hidden)
    }
  }

  override func prepareForReuse() {
    super.prepareForReuse()

    clipThumbnailImageView.image = nil
    setAvatarBouncing(false)
  }

  // MARK: - Private

  private func dimContentView(dim: Bool) {
    dimView.hidden = !dim
  }

  private func scaleClipThumbnail(down: Bool, isCurrentPlayingClip: Bool, animated: Bool) {
    if animated {
      UIView.animateWithDuration(0.4) {
        self.scaleClipThumbnail(down, isCurrentPlayingClip: isCurrentPlayingClip, animated: false)
      }
    } else {
      if down {
        // We used to scale current clip to 0.857 and non-current clip to 0.75
        // Removed for Jef testing. If it doesn't come back, remove `isCurrentPlayingClip`
        clipThumbnailImageView.transform = CGAffineTransformMakeScale(0.857, 0.857)
      } else {
        clipThumbnailImageView.transform = CGAffineTransformMakeScale(1.0, 1.0)
      }
    }
  }

  private func hideUserInfo(hidden: Bool, animated: Bool) {
    if animated {
      UIView.animateWithDuration(0.2) {
        self.hideUserInfo(hidden, animated: false)
      }
    } else {
      let alpha = CGFloat(!hidden)
      userAvatarImageView.alpha = alpha
      usernameLabel.alpha = alpha
      clipTimeLabel.alpha = alpha
      likeButton.alpha = alpha
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

  private func setAvatarConstraintForTopOfBounce(topOfBounce: Bool) {
    if topOfBounce {
      userAvatarImageViewYConstraint = constrain(userAvatarImageView, clipThumbnailImageView, replace: userAvatarImageViewYConstraint) { (userAvatarImageView, clipThumbnailImageView) in
        userAvatarImageView.centerY == clipThumbnailImageView.bottom - 75
      }
    } else {
      if userAvatarImageViewYConstraint == nil {
        userAvatarImageViewYConstraint = constrain(userAvatarImageView, clipThumbnailImageView) { (userAvatarImageView, clipThumbnailImageView) in
          userAvatarImageView.centerY == clipThumbnailImageView.bottom
        }
      } else {
        userAvatarImageViewYConstraint = constrain(userAvatarImageView, clipThumbnailImageView, replace: userAvatarImageViewYConstraint) { (userAvatarImageView, clipThumbnailImageView) in
          userAvatarImageView.centerY == clipThumbnailImageView.bottom
        }
      }
    }
  }

  private func setAvatarBouncing(bounce: Bool) {
    if bounce {
      userAvatarImageView.layer.removeAllAnimations()
      // Move the avatar up
      setAvatarConstraintForTopOfBounce(true)
      UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseOut,
        animations: { () -> Void in
          self.userAvatarImageView.layoutIfNeeded()
        }) { (animated) -> Void in
          self.setAvatarConstraintForTopOfBounce(false)
          UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.userAvatarImageView.layoutIfNeeded()
            }, completion: { (finished) -> Void in
              if finished {
                self.setAvatarBouncing(true)
              }
          })
      }
      // Spin the avatar around 360 degress
      UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
        self.userAvatarImageView.transform = CGAffineTransformRotate(self.userAvatarImageView.transform, CGFloat(M_PI))
        }) { (completed) -> Void in
          UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            self.userAvatarImageView.transform = CGAffineTransformRotate(self.userAvatarImageView.transform, CGFloat(M_PI))
            }, completion: nil)
      }
    } else {
      userAvatarImageView.layer.removeAllAnimations()
      setAvatarConstraintForTopOfBounce(false)
      userAvatarImageView.layoutIfNeeded()
    }
  }

  @objc private func showOptionsGestureRecognizerSwiped() {
    showOptionsViewAnimated(true)
  }

  @objc private func showOptionsGestureRecognizerLongPressed() {
    showOptionsViewAnimated(true)
  }

  @objc private func hideOptionsGestureRecognizerSwiped() {
    hideOptionsViewAnimated(true)
  }

  @objc private func userButtonTapped() {
    delegate?.userDidTapUserButtonForCell(self)
  }

  @objc private func likeButtonTapped() {
    delegate?.userDidTapLikeButtonForCell(self)
  }
}

// MARK: -

protocol ClipCollectionViewCellDelegate {
  func userDidDeleteClipForCell(cell: ClipCollectionViewCell)
  func userDidFlagClipForCell(cell: ClipCollectionViewCell)
  func userDidTapUserButtonForCell(cell: ClipCollectionViewCell)
  func userDidTapLikeButtonForCell(cell: ClipCollectionViewCell)
}

// MARK: -

extension ClipCollectionViewCell: ClipOptionsViewDelegate {

  // MARK: - ClipOptionsViewDelegate

  func userDidSelectFlagClipOption() {
    hideOptionsViewAnimated(true)
    delegate?.userDidFlagClipForCell(self)
  }

  func userDidSelectDeleteClipOption() {
    hideOptionsViewAnimated(true)
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