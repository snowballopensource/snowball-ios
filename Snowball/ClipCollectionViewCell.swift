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
  case Bookmarked
  case PlayingIdle
  case PlayingActive
  case PendingUpload
  case Uploading
  case Options
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

  var delegate: ClipCollectionViewCellDelegate?

  private let clipThumbnailImageView = UIImageView()

  private let addClipImageView: UIImageView = {
    let imageView = UIImageView(image: UIImage(named: "add-clip"))
    imageView.backgroundColor = User.currentUser?.color as? UIColor ?? UIColor.SnowballColor.blueColor
    imageView.contentMode = UIViewContentMode.Center
    return imageView
    }()

  private let userAvatarImageView = UserAvatarImageView()
  private var userAvatarImageViewYConstraint = ConstraintGroup()
  private var userAvatarShouldContinueBouncing = false
  private var userAvatarBounceInProgress = false
  private let userButton = UIButton()

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

  private let bookmarkImageView = UIImageView(image: UIImage(named: "play"))

  private let dimOverlayView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.whiteColor()
    return view
    }()

  private let optionsView = ClipOptionsView()
  private var optionsViewYConstraint = ConstraintGroup()

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

  // MARK: - Initializers

  override init(frame: CGRect) {
    super.init(frame: frame)

    setupSubviews()

    userButton.addTarget(self, action: "userButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)

    likeButton.addTarget(self, action: "likeButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)

    optionsView.delegate = self

    showOptionsGestureRecognizer.addTarget(self, action: "showOptionsGestureRecognizerSwiped")
    addGestureRecognizer(showOptionsGestureRecognizer)
    hideOptionsGestureRecognizer.addTarget(self, action: "hideOptionsGestureRecognizerSwiped")
    addGestureRecognizer(hideOptionsGestureRecognizer)
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
      optionsView.configureForUser(user)
    }

    usernameLabel.text = clip.user?.username
    usernameLabel.textColor = userColor

    clipTimeLabel.text = clip.createdAt?.shortTimeSinceString()

    setClipLiked(clip.liked, animated: false)
    likeButton.tintColor = userColor
    likeButton.hidden = false
    if clip.user == User.currentUser {
      likeButton.hidden = true
    }

    if clip.state == ClipState.PendingUpload {
      setState(ClipCollectionViewCellState.PendingUpload, animated: false)
    } else {
      setState(state, animated: false)
    }
  }

  func setState(state: ClipCollectionViewCellState, animated: Bool) {
    let bookmarked = (state == .Bookmarked)
    hideBookmarkImage(!bookmarked, animated: animated)

    let playingIdle = (state == .PlayingIdle)
    let playingActive = (state == .PlayingActive)
    scaleClipThumbnail((playingIdle || playingActive), animated: animated)
    hideDimOverlay(!playingIdle, animated: animated)
    hideClipInfo(playingIdle, animated: animated)

    let pendingUpload = (state == .PendingUpload)
    addClipImageView.hidden = !pendingUpload
    clipTimeLabel.hidden = pendingUpload

    let uploading = (state == .Uploading)
    setUserAvatarBouncing(uploading)

    let options = (state == .Options)
    hideOptionsView(!options, animated: animated)
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

    contentView.addSubview(addClipImageView)
    layout(addClipImageView, clipThumbnailImageView) { (addClipImageView, clipThumbnailImageView) in
      addClipImageView.left == clipThumbnailImageView.left
      addClipImageView.top == clipThumbnailImageView.top
      addClipImageView.right == clipThumbnailImageView.right
      addClipImageView.bottom == clipThumbnailImageView.bottom
    }

    contentView.addSubview(optionsView)
    setOptionsViewYConstraint(hidden: true)
    layout(optionsView, clipThumbnailImageView) { (optionsView, clipThumbnailImageView) in
      optionsView.left == clipThumbnailImageView.left
      optionsView.width == clipThumbnailImageView.width
      optionsView.height == clipThumbnailImageView.height
    }

    contentView.addSubview(userAvatarImageView)
    setUserAvatarImageViewYConstraint()
    layout(userAvatarImageView, clipThumbnailImageView) { (userAvatarImageView, clipThumbnailImageView) in
      var width: Float = 40
      if isIphone4S { width = 30 }
      userAvatarImageView.centerX == userAvatarImageView.superview!.centerX
      userAvatarImageView.width == width
      userAvatarImageView.height == userAvatarImageView.width
    }

    contentView.addSubview(userButton)
    layout(userButton, userAvatarImageView) { (userButton, userAvatarImageView) in
      userButton.left == userAvatarImageView.left
      userButton.top == userAvatarImageView.top
      userButton.right == userAvatarImageView.right
      userButton.bottom == userAvatarImageView.bottom
    }

    contentView.addSubview(usernameLabel)
    layout(usernameLabel, clipThumbnailImageView) { (usernameLabel, clipThumbnailImageView) in
      usernameLabel.centerX == usernameLabel.superview!.centerX
      usernameLabel.top == clipThumbnailImageView.bottom + (self.userAvatarImageView.frame.height / 2) + 5
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

    contentView.addSubview(bookmarkImageView)
    layout(bookmarkImageView, clipThumbnailImageView) { (bookmarkImageView, clipThumbnailImageView) in
      bookmarkImageView.centerX == clipThumbnailImageView.centerX
      bookmarkImageView.centerY == clipThumbnailImageView.centerY
    }

    contentView.addSubview(dimOverlayView)
    layout(dimOverlayView) { (dimOverlayView) in
      dimOverlayView.left == dimOverlayView.superview!.left
      dimOverlayView.top == dimOverlayView.superview!.top
      dimOverlayView.right == dimOverlayView.superview!.right
      dimOverlayView.bottom == dimOverlayView.superview!.bottom
    }
  }

  private func setClipLiked(liked: Bool, animated: Bool) {
    if liked && animated {
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
    likeButton.selected = liked
  }

  private func scaleClipThumbnail(down: Bool, animated: Bool) {
    if animated {
      UIView.animateWithDuration(0.4) {
        self.scaleClipThumbnail(down, animated: false)
      }
    } else {
      if down {
        clipThumbnailImageView.transform = CGAffineTransformMakeScale(0.857, 0.857)
      } else {
        clipThumbnailImageView.transform = CGAffineTransformMakeScale(1.0, 1.0)
      }
    }
  }

  private func hideClipInfo(hidden: Bool, animated: Bool) {
    if animated {
      UIView.animateWithDuration(0.4) {
        self.hideClipInfo(hidden, animated: false)
      }
    } else {
      let alpha = CGFloat(!hidden)
      userAvatarImageView.alpha = alpha
      usernameLabel.alpha = alpha
      clipTimeLabel.alpha = alpha
      likeButton.alpha = alpha
    }
  }

  private func hideDimOverlay(hidden: Bool, animated: Bool) {
    if animated {
      UIView.animateWithDuration(0.4) {
        self.hideDimOverlay(hidden, animated: false)
      }
    } else {
      var alpha: CGFloat = 0.6
      if hidden { alpha = 0 }
      dimOverlayView.alpha = alpha
    }
  }

  private func hideBookmarkImage(hidden: Bool, animated: Bool) {
    if animated {
      UIView.animateWithDuration(0.4) {
        self.hideBookmarkImage(hidden, animated: false)
      }
    } else {
      let alpha = CGFloat(!hidden)
      bookmarkImageView.alpha = alpha
    }
  }

  @objc private func userButtonTapped() {
    delegate?.userDidTapUserButtonForCell(self)
  }

  @objc private func likeButtonTapped() {
    let liked = likeButton.selected
    setClipLiked(!liked, animated: true)
    delegate?.userDidTapLikeButtonForCell(self)
  }

  private func setUserAvatarBouncing(bounce: Bool) {
    if !bounce { userAvatarShouldContinueBouncing = false; return }
    if bounce && !userAvatarBounceInProgress {
      userAvatarBounceInProgress = true
      userAvatarShouldContinueBouncing = true
      setUserAvatarImageViewYConstraint(topOfBounce: true)
      UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseOut,
        animations: { () -> Void in
          self.userAvatarImageView.layoutIfNeeded()
        }) { (completed) -> Void in
          self.setUserAvatarImageViewYConstraint(topOfBounce: false)
          UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.userAvatarImageView.layoutIfNeeded()
            }) { (completed) -> Void in
              self.userAvatarBounceInProgress = false
              self.setUserAvatarBouncing(self.userAvatarShouldContinueBouncing)
          }
      }
      UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
        self.userAvatarImageView.transform = CGAffineTransformRotate(self.userAvatarImageView.transform, CGFloat(M_PI))
        }) { (completed) -> Void in
          UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            self.userAvatarImageView.transform = CGAffineTransformRotate(self.userAvatarImageView.transform, CGFloat(M_PI))
            }, completion: nil)
      }
    }
  }

  private func setUserAvatarImageViewYConstraint(topOfBounce: Bool = false) {
    if topOfBounce {
      userAvatarImageViewYConstraint = constrain(userAvatarImageView, clipThumbnailImageView, replace: userAvatarImageViewYConstraint) { (userAvatarImageView, clipThumbnailImageView) in
        userAvatarImageView.centerY == clipThumbnailImageView.bottom - 75
      }
    } else {
      userAvatarImageViewYConstraint = constrain(userAvatarImageView, clipThumbnailImageView, replace: userAvatarImageViewYConstraint) { (userAvatarImageView, clipThumbnailImageView) in
        userAvatarImageView.centerY == clipThumbnailImageView.bottom
      }
    }
  }

  private func hideOptionsView(hidden: Bool, animated: Bool) {
    if animated {
      UIView.animateWithDuration(0.2) {
        self.hideOptionsView(hidden, animated: false)
      }
    } else {
      setOptionsViewYConstraint(hidden: hidden)
      optionsView.layoutIfNeeded()
    }
  }

  private func setOptionsViewYConstraint(#hidden: Bool) {
    if hidden {
      optionsViewYConstraint = constrain(optionsView, clipThumbnailImageView, replace: optionsViewYConstraint) { (optionsView, clipThumbnailImageView) in
        optionsView.bottom == clipThumbnailImageView.top
      }
    } else {
      userAvatarImageViewYConstraint = constrain(optionsView, clipThumbnailImageView, replace: optionsViewYConstraint) { (optionsView, clipThumbnailImageView) in
        optionsView.bottom == clipThumbnailImageView.bottom
      }
    }
  }

  @objc private func showOptionsGestureRecognizerSwiped() {
    hideOptionsView(false, animated: true)
  }

  @objc private func hideOptionsGestureRecognizerSwiped() {
    hideOptionsView(true, animated: true)
  }
}

// MARK: -
protocol ClipCollectionViewCellDelegate {
  func userDidTapDeleteButtonForCell(cell: ClipCollectionViewCell)
  func userDidTapFlagButtonForCell(cell: ClipCollectionViewCell)
  func userDidTapUserButtonForCell(cell: ClipCollectionViewCell)
  func userDidTapLikeButtonForCell(cell: ClipCollectionViewCell)
}

// MARK: - ClipOptionsViewDelegate
extension ClipCollectionViewCell: ClipOptionsViewDelegate {

  func userDidTapFlagButton() {
    delegate?.userDidTapFlagButtonForCell(self)
  }

  func userDidTapDeleteButton() {
    delegate?.userDidTapDeleteButtonForCell(self)
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

  convenience init() {
    self.init(frame: CGRectZero)

    addSubview(flagButton)
    flagButton.addTarget(self, action: "flagButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    addSubview(deleteButton)
    deleteButton.addTarget(self, action: "deleteButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
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
        if user == currentUser {
          deleteButton.hidden = false
        } else {
          flagButton.hidden = false
        }
      }
    }
  }

  // MARK: - Private

  @objc private func flagButtonTapped() {
    delegate?.userDidTapFlagButton()
  }

  @objc private func deleteButtonTapped() {
    delegate?.userDidTapDeleteButton()
  }
}

// MARK: -
protocol ClipOptionsViewDelegate {
  func userDidTapFlagButton()
  func userDidTapDeleteButton()
}