//
//  ClipCollectionViewCell.swift
//  Snowball
//
//  Created by James Martinez on 12/13/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import Cartography
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

  var delegate: ClipCollectionViewCellDelegate?

  let longPressGestureRecognizer = UILongPressGestureRecognizer()

  let thumbnailImageView = UIImageView()
  let playImageView: UIImageView = {
    let imageView = UIImageView(image: UIImage(named: "cell-clip-play"))
    imageView.contentMode = .Center
    imageView.tintColor = UIColor.whiteColor()
    return imageView
  }()
  let pauseImageView: UIImageView = {
    let imageView = UIImageView(image: UIImage(named: "cell-clip-pause"))
    imageView.contentMode = .Center
    imageView.tintColor = UIColor.whiteColor()
    return imageView
  }()
  let playButton = UIButton()
  let addButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(named: "cell-clip-add"), forState: UIControlState.Normal)
    button.backgroundColor = User.currentUser?.color
    return button
  }()
  let retryUploadButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(named: "cell-clip-retry"), forState: UIControlState.Normal)
    return button
  }()

  let optionsView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
    return view
  }()
  let deleteImageView: UIImageView = {
    let imageView = UIImageView(image: UIImage(named: "cell-clip-delete"))
    imageView.contentMode = .Center
    return imageView
  }()
  let flagImageView: UIImageView = {
    let imageView = UIImageView(image: UIImage(named: "cell-clip-flag"))
    imageView.contentMode = .Center
    return imageView
  }()
  let optionsButton = UIButton()

  let userAvatarImageView = UserAvatarImageView()
  private let userAvatarImageViewBounceConstraintGroup = ConstraintGroup()
  private let userAvatarImageViewBounceDuration = 1.0
  private var userAvatarImageViewBounceInProgress = false
  private var userAvatarImageViewShouldContinueBouncing = false

  let profileButton = UIButton()
  let usernameLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.SnowballFont.mediumFont.fontWithSize(14)
    label.textAlignment = .Center
    return label
  }()
  let timeAgoLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.SnowballFont.mediumFont.fontWithSize(12)
    label.textColor = UIColor.SnowballColor.lightGrayColor
    label.textAlignment = .Center
    return label
  }()

  let likeButton: UIButton = {
    let button = UIButton()
    let heartImage = UIImage(named: "cell-clip-heart")
    let heartFilledImage = UIImage(named: "cell-clip-heart-filled")
    button.setImage(heartImage, forState: .Normal)
    button.setImage(heartFilledImage, forState: .Selected)
    button.setImage(heartFilledImage, forState: .Highlighted)
    return button
  }()

  let dimOverlayView: UIView = {
    let view = UIView()
    view.userInteractionEnabled = false
    view.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
    return view
  }()

  // MARK: Initializers

  override init(frame: CGRect) {
    super.init(frame: frame)

    addSubview(thumbnailImageView)
    constrain(thumbnailImageView) { thumbnailImageView in
      thumbnailImageView.left == thumbnailImageView.superview!.left
      thumbnailImageView.top == thumbnailImageView.superview!.top
      thumbnailImageView.right == thumbnailImageView.superview!.right
      thumbnailImageView.height == thumbnailImageView.width
    }
    addGestureRecognizer(longPressGestureRecognizer)
    longPressGestureRecognizer.addTarget(self, action: "longPressGestureRecognizerTriggered")

    addSubview(playImageView)
    constrain(playImageView, thumbnailImageView) { playImageView, thumbnailImageView in
      playImageView.left == thumbnailImageView.left
      playImageView.top == thumbnailImageView.top
      playImageView.right == thumbnailImageView.right
      playImageView.bottom == thumbnailImageView.bottom
    }

    addSubview(pauseImageView)
    constrain(pauseImageView, playImageView) { pauseImageView, playImageView in
      pauseImageView.left == playImageView.left
      pauseImageView.top == playImageView.top
      pauseImageView.right == playImageView.right
      pauseImageView.bottom == playImageView.bottom
    }

    addSubview(playButton)
    constrain(playButton, thumbnailImageView) { (playButton, thumbnailImageView) in
      playButton.left == thumbnailImageView.left
      playButton.top == thumbnailImageView.top
      playButton.right == thumbnailImageView.right
      playButton.height == thumbnailImageView.height
    }
    playButton.addTarget(self, action: "playButtonTapped", forControlEvents: .TouchUpInside)

    addSubview(addButton)
    constrain(addButton, thumbnailImageView) { addButton, thumbnailImageView in
      addButton.left == thumbnailImageView.left
      addButton.top == thumbnailImageView.top
      addButton.right == thumbnailImageView.right
      addButton.bottom == thumbnailImageView.bottom
    }
    addButton.addTarget(self, action: "addButtonTapped", forControlEvents: .TouchUpInside)

    addSubview(retryUploadButton)
    constrain(retryUploadButton, thumbnailImageView) { retryUploadButton, thumbnailImageView in
      retryUploadButton.left == thumbnailImageView.left
      retryUploadButton.top == thumbnailImageView.top
      retryUploadButton.right == thumbnailImageView.right
      retryUploadButton.bottom == thumbnailImageView.bottom
    }
    retryUploadButton.addTarget(self, action: "retryUploadButtonTapped", forControlEvents: .TouchUpInside)

    addSubview(optionsView)
    constrain(optionsView, thumbnailImageView) { optionsView, thumbnailImageView in
      optionsView.left == thumbnailImageView.left
      optionsView.top == thumbnailImageView.top
      optionsView.right == thumbnailImageView.right
      optionsView.bottom == thumbnailImageView.bottom
    }

    optionsView.addSubview(deleteImageView)
    constrain(deleteImageView) { deleteImageView in
      deleteImageView.left == deleteImageView.superview!.left
      deleteImageView.top == deleteImageView.superview!.top
      deleteImageView.right == deleteImageView.superview!.right
      deleteImageView.bottom == deleteImageView.superview!.bottom
    }

    optionsView.addSubview(flagImageView)
    constrain(flagImageView) { flagImageView in
      flagImageView.left == flagImageView.superview!.left
      flagImageView.top == flagImageView.superview!.top
      flagImageView.right == flagImageView.superview!.right
      flagImageView.bottom == flagImageView.superview!.bottom
    }

    optionsView.addSubview(optionsButton)
    constrain(optionsButton) { optionsButton in
      optionsButton.left == optionsButton.superview!.left
      optionsButton.top == optionsButton.superview!.top
      optionsButton.right == optionsButton.superview!.right
      optionsButton.bottom == optionsButton.superview!.bottom
    }
    optionsButton.addTarget(self, action: "optionsButtonTapped", forControlEvents: .TouchUpInside)

    let userAvatarImageViewWidthHeight: CGFloat = 40
    addSubview(userAvatarImageView)
    constrain(userAvatarImageView) { userAvatarImageView in
      userAvatarImageView.centerX == userAvatarImageView.superview!.centerX
      userAvatarImageView.width == userAvatarImageViewWidthHeight
      userAvatarImageView.height == userAvatarImageView.width
    }
    setUserAvatarImageViewBounceConstraints()

    addSubview(profileButton)
    constrain(profileButton, userAvatarImageView) { (profileButton, userAvatarImageView) in
      profileButton.left == userAvatarImageView.left
      profileButton.top == userAvatarImageView.top
      profileButton.right == userAvatarImageView.right
      profileButton.height == userAvatarImageView.height
    }
    profileButton.addTarget(self, action: "profileButtonTapped", forControlEvents: .TouchUpInside)

    addSubview(usernameLabel)
    constrain(usernameLabel, thumbnailImageView, userAvatarImageView) { usernameLabel, thumbnailImageView, userAvatarImageView in
      usernameLabel.left == usernameLabel.superview!.left
      usernameLabel.top == thumbnailImageView.bottom + (userAvatarImageViewWidthHeight / 2) + 7
      usernameLabel.right == usernameLabel.superview!.right
    }

    addSubview(timeAgoLabel)
    constrain(timeAgoLabel, usernameLabel) { timeAgoLabel, usernameLabel in
      timeAgoLabel.left == timeAgoLabel.superview!.left
      timeAgoLabel.top == usernameLabel.bottom + 4
      timeAgoLabel.right == timeAgoLabel.superview!.right
    }

    addSubview(likeButton)
    constrain(likeButton, timeAgoLabel) { likeButton, timeAgoLabel  in
      likeButton.top == timeAgoLabel.bottom + 18
      likeButton.centerX == likeButton.superview!.centerX
      likeButton.width == 35
      likeButton.height == 30
    }
    likeButton.addTarget(self, action: "likeButtonTapped", forControlEvents: .TouchUpInside)

    addSubview(dimOverlayView)
    constrain(dimOverlayView) { dimOverlayView in
      dimOverlayView.left == dimOverlayView.superview!.left
      dimOverlayView.top == dimOverlayView.superview!.top
      dimOverlayView.right == dimOverlayView.superview!.right
      dimOverlayView.bottom == dimOverlayView.superview!.bottom
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: UICollectionViewCell

  override func prepareForReuse() {
    thumbnailImageView.image = nil
    userAvatarImageView.image = nil
  }

  // MARK: Internal

  func configueForClip(clip: Clip, state: ClipCollectionViewCellState = .Default, animated: Bool = false) {
    if let thumbnailURLString = clip.thumbnailURL, thumbnailURL = NSURL(string: thumbnailURLString) {
      thumbnailImageView.setImageFromURL(thumbnailURL)
    }
    if let user = clip.user {
      userAvatarImageView.setUser(user)

      usernameLabel.textColor = user.color
      usernameLabel.text = user.username

      let isCurrentUser = (user == User.currentUser)
      deleteImageView.hidden = !isCurrentUser
      flagImageView.hidden = isCurrentUser
    }

    timeAgoLabel.text = clip.createdAt?.shortTimeSinceString() ?? NSLocalizedString("Now", comment: "")

    likeButton.highlighted = clip.liked

    setState(state, animated: animated)
  }

  func setState(state: ClipCollectionViewCellState, animated: Bool) {
    let bookmarked = state == .Bookmarked
    let options = state == .Options
    let playingIdle = state == .PlayingIdle
    let playingActive = state == .PlayingActive
    let playing = (playingIdle || playingActive)
    let pendingAcceptance = state == .PendingAcceptance
    let uploading = state == .Uploading
    let uploadFailed = state == .UploadFailed

    playImageView.setHidden(!(bookmarked && !options), animated: animated)
    pauseImageView.setHidden(!playingActive, animated: animated)
    setThumbnailScaledDown(playing, animated: animated)
    dimOverlayView.setHidden(!playingIdle, animated: animated)
    addButton.setHidden(!pendingAcceptance, animated: animated)
    retryUploadButton.setHidden(!uploadFailed, animated: animated)
    optionsView.setHidden(!options, animated: animated)
    usernameLabel.setHidden(playingIdle, animated: animated)
    timeAgoLabel.setHidden(playingIdle, animated: animated)
    userAvatarImageView.setHidden(playingIdle, animated: animated)
    likeButton.setHidden(playingIdle, animated: animated)

    profileButton.userInteractionEnabled = !playing

    if uploading {
      userAvatarImageViewBeginBouncing()
    } else {
      userAvatarImageViewStopBouncingAnimated(animated)
    }
  }

  // MARK: Private

  @objc private func playButtonTapped() {
    delegate?.clipCollectionViewCellPlayButtonTapped(self)
  }

  @objc private func addButtonTapped() {
    delegate?.clipCollectionViewCellAddButtonTapped(self)
  }

  @objc private func retryUploadButtonTapped() {
    delegate?.clipCollectionViewCellRetryUploadButtonTapped(self)
  }

  @objc private func profileButtonTapped() {
    delegate?.clipCollectionViewCellProfileButtonTapped(self)
  }

  @objc private func longPressGestureRecognizerTriggered() {
    delegate?.clipCollectionViewCellLongPressTriggered(self)
  }

  @objc private func optionsButtonTapped() {
    delegate?.clipCollectionViewCellOptionsButtonTapped(self)
  }

  @objc private func likeButtonTapped() {
    delegate?.clipCollectionViewCellLikeButtonTapped(self)
  }

  private func setThumbnailScaledDown(scaledDown: Bool, animated: Bool) {
    if animated {
      UIView.animateWithDuration(0.4) {
        self.setThumbnailScaledDown(scaledDown, animated: false)
      }
    } else {
      if scaledDown {
        thumbnailImageView.transform = CGAffineTransformMakeScale(0.857, 0.857)
      } else {
        thumbnailImageView.transform = CGAffineTransformMakeScale(1.0, 1.0)
      }
    }
  }

  private func setUserAvatarImageViewBounceConstraints(position: Int = 0) {
    // 0 through 2, to represent the keyframes of the animation.
    // 0 is start of bounce, 2 is top of bounce
    let bounceHeight = ClipCollectionViewCell.defaultSize.width / 4 * 3
    constrain(userAvatarImageView, thumbnailImageView, replace: userAvatarImageViewBounceConstraintGroup) { userAvatarImageView, thumbnailImageView in
      switch position {
      case 0: userAvatarImageView.centerY == thumbnailImageView.bottom
      case 1: userAvatarImageView.centerY == thumbnailImageView.bottom - (bounceHeight / 2)
      case 2: userAvatarImageView.centerY == thumbnailImageView.bottom - bounceHeight
      default: fatalError("setUserAvatarImageViewBounceConstraints(position:) position must be between 0 and 4")
      }
    }
  }

  private func userAvatarImageViewBeginBouncing() {
    if userAvatarImageViewBounceInProgress { return }
    userAvatarImageViewBounceInProgress = true
    userAvatarImageViewShouldContinueBouncing = true
    _spinUserAvatarImageView()
    _bounceUserAvatarImageView()
  }

  private func userAvatarImageViewStopBouncingAnimated(animated: Bool) {
    userAvatarImageViewShouldContinueBouncing = false
    if !animated {
      userAvatarImageView.layer.removeAllAnimations()
      userAvatarImageView.transform = CGAffineTransformIdentity
    }
  }

  private func _bounceUserAvatarImageView(toTop toTop: Bool = true) {
    let animationCurve = (toTop) ? UIViewAnimationOptions.CurveEaseOut : UIViewAnimationOptions.CurveEaseIn
    UIView.animateKeyframesWithDuration(userAvatarImageViewBounceDuration / 2,
      delay: 0,
      options: [.CalculationModePaced, UIViewKeyframeAnimationOptions(rawValue: animationCurve.rawValue)],
      animations: {
        if toTop {
          UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0) {
            self.setUserAvatarImageViewBounceConstraints(1)
            self.userAvatarImageView.setNeedsLayout()
            self.userAvatarImageView.layoutIfNeeded()
          }
          UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0) {
            self.setUserAvatarImageViewBounceConstraints(2)
            self.userAvatarImageView.setNeedsLayout()
            self.userAvatarImageView.layoutIfNeeded()
          }
        } else {
          UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0) {
            self.setUserAvatarImageViewBounceConstraints(1)
            self.userAvatarImageView.setNeedsLayout()
            self.userAvatarImageView.layoutIfNeeded()
          }
          UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0) {
            self.setUserAvatarImageViewBounceConstraints(0)
            self.userAvatarImageView.setNeedsLayout()
            self.userAvatarImageView.layoutIfNeeded()
          }
        }
      },
      completion: { finished in
        if finished && self.userAvatarImageViewShouldContinueBouncing {
          self._bounceUserAvatarImageView(toTop: !toTop)
        } else {
          self.userAvatarImageViewBounceInProgress = false
          if toTop {
            // If was animating to top, but animation was cancelled, reset to bottom.
            self.setUserAvatarImageViewBounceConstraints(0)
            self.userAvatarImageView.setNeedsLayout()
            self.userAvatarImageView.layoutIfNeeded()
          }
        }
    })
  }

  private func _spinUserAvatarImageView() {
    let fullRotation = CGFloat(M_PI * -2)
    UIView.animateKeyframesWithDuration(userAvatarImageViewBounceDuration,
      delay: 0,
      options: [.CalculationModePaced, UIViewKeyframeAnimationOptions(rawValue: UIViewAnimationOptions.CurveLinear.rawValue)],
      animations: {
        UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0) {
          self.userAvatarImageView.transform = CGAffineTransformMakeRotation(fullRotation * 1/3)
        }
        UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0) {
          self.userAvatarImageView.transform = CGAffineTransformMakeRotation(fullRotation * 2/3)
        }
        UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0) {
          self.userAvatarImageView.transform = CGAffineTransformMakeRotation(fullRotation * 3/3)
        }
      },
      completion: { finished in
        if finished && self.userAvatarImageViewShouldContinueBouncing {
          self._spinUserAvatarImageView()
        } else {
          self.userAvatarImageViewBounceInProgress = false
        }
    })
  }
}

// MARK: - ClipCollectionViewCellDelegate
protocol ClipCollectionViewCellDelegate {
  func clipCollectionViewCellPlayButtonTapped(cell: ClipCollectionViewCell)
  func clipCollectionViewCellAddButtonTapped(cell: ClipCollectionViewCell)
  func clipCollectionViewCellRetryUploadButtonTapped(cell: ClipCollectionViewCell)
  func clipCollectionViewCellProfileButtonTapped(cell: ClipCollectionViewCell)
  func clipCollectionViewCellLongPressTriggered(cell: ClipCollectionViewCell)
  func clipCollectionViewCellOptionsButtonTapped(cell: ClipCollectionViewCell)
  func clipCollectionViewCellLikeButtonTapped(cell: ClipCollectionViewCell)
}

// MARK: - ClipCollectionViewCellState
enum ClipCollectionViewCellState {
  case Default
  case Bookmarked
  case Options
  case PlayingIdle
  case PlayingActive
  case PendingAcceptance
  case Uploading
  case UploadFailed
}
