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
    let screenHeight = UIScreen.main.bounds.height
    let screenWidth = UIScreen.main.bounds.width
    let cellHeight = screenHeight - screenWidth
    let cellsPerScreen: CGFloat = 2.5
    let cellWidth = screenWidth / cellsPerScreen
    return CGSize(width: cellWidth, height: cellHeight)
  }

  var delegate: ClipCollectionViewCellDelegate?

  let longPressGestureRecognizer = UILongPressGestureRecognizer()

  let thumbnailImageView = UIImageView()
  let playImageView: UIImageView = {
    let imageView = UIImageView(image: UIImage(named: "cell-clip-play"))
    imageView.contentMode = .center
    imageView.tintColor = UIColor.white
    return imageView
  }()
  let pauseImageView: UIImageView = {
    let imageView = UIImageView(image: UIImage(named: "cell-clip-pause"))
    imageView.contentMode = .center
    imageView.tintColor = UIColor.white
    return imageView
  }()
  let playButton = UIButton()
  let addButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(named: "cell-clip-add"), for: UIControlState())
    button.backgroundColor = User.currentUser?.color
    return button
  }()
  let retryUploadButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(named: "cell-clip-retry"), for: UIControlState())
    return button
  }()

  let optionsView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.red.withAlphaComponent(0.5)
    return view
  }()
  let deleteImageView: UIImageView = {
    let imageView = UIImageView(image: UIImage(named: "cell-clip-delete"))
    imageView.contentMode = .center
    return imageView
  }()
  let flagImageView: UIImageView = {
    let imageView = UIImageView(image: UIImage(named: "cell-clip-flag"))
    imageView.contentMode = .center
    return imageView
  }()

  let userAvatarImageView = UserAvatarImageView()
  fileprivate let userAvatarImageViewBounceConstraintGroup = ConstraintGroup()
  fileprivate let userAvatarImageViewBounceDuration = 1.0
  fileprivate var userAvatarImageViewBounceInProgress = false
  fileprivate var userAvatarImageViewShouldContinueBouncing = false

  let profileButton = UIButton()
  let usernameLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.SnowballFont.mediumFont.withSize(14)
    label.textAlignment = .center
    return label
  }()
  let timeAgoLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.SnowballFont.mediumFont.withSize(12)
    label.textColor = UIColor.SnowballColor.lightGrayColor
    label.textAlignment = .center
    return label
  }()

  let likeButton: UIButton = {
    let button = UIButton()
    let heartImage = UIImage(named: "cell-clip-heart")
    let heartFilledImage = UIImage(named: "cell-clip-heart-filled")
    button.setImage(heartImage, for: UIControlState())
    button.setImage(heartFilledImage, for: .selected)
    button.setImage(heartFilledImage, for: .highlighted)
    return button
  }()

  let dimOverlayView: UIView = {
    let view = UIView()
    view.isUserInteractionEnabled = false
    view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
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
    longPressGestureRecognizer.addTarget(self, action: #selector(ClipCollectionViewCell.longPressGestureRecognizerTriggered))

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
    playButton.addTarget(self, action: #selector(ClipCollectionViewCell.playButtonTapped), for: .touchUpInside)

    addSubview(addButton)
    constrain(addButton, thumbnailImageView) { addButton, thumbnailImageView in
      addButton.left == thumbnailImageView.left
      addButton.top == thumbnailImageView.top
      addButton.right == thumbnailImageView.right
      addButton.bottom == thumbnailImageView.bottom
    }
    addButton.addTarget(self, action: #selector(ClipCollectionViewCell.addButtonTapped), for: .touchUpInside)

    addSubview(retryUploadButton)
    constrain(retryUploadButton, thumbnailImageView) { retryUploadButton, thumbnailImageView in
      retryUploadButton.left == thumbnailImageView.left
      retryUploadButton.top == thumbnailImageView.top
      retryUploadButton.right == thumbnailImageView.right
      retryUploadButton.bottom == thumbnailImageView.bottom
    }
    retryUploadButton.addTarget(self, action: #selector(ClipCollectionViewCell.retryUploadButtonTapped), for: .touchUpInside)

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
    profileButton.addTarget(self, action: #selector(ClipCollectionViewCell.profileButtonTapped), for: .touchUpInside)

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
    likeButton.addTarget(self, action: #selector(ClipCollectionViewCell.likeButtonTapped), for: .touchUpInside)

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

  func configueForClip(_ clip: Clip, state: ClipCollectionViewCellState = .default, animated: Bool = false) {
    if let thumbnailURLString = clip.thumbnailURL, let thumbnailURL = URL(string: thumbnailURLString) {
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

    likeButton.isHighlighted = clip.liked

    setState(state, animated: animated)
  }

  func setState(_ state: ClipCollectionViewCellState, animated: Bool) {
    let bookmarked = state == .bookmarked
    let options = state == .options
    let playingIdle = state == .playingIdle
    let playingActive = state == .playingActive
    let playing = (playingIdle || playingActive)
    let pendingAcceptance = state == .pendingAcceptance
    let uploading = state == .uploading
    let uploadFailed = state == .uploadFailed

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

    profileButton.isUserInteractionEnabled = !playing

    if uploading {
      userAvatarImageViewBeginBouncing()
    } else {
      userAvatarImageViewStopBouncingAnimated(animated)
    }
  }

  // MARK: Private

  @objc fileprivate func playButtonTapped() {
    delegate?.clipCollectionViewCellPlayButtonTapped(self)
  }

  @objc fileprivate func addButtonTapped() {
    delegate?.clipCollectionViewCellAddButtonTapped(self)
  }

  @objc fileprivate func retryUploadButtonTapped() {
    delegate?.clipCollectionViewCellRetryUploadButtonTapped(self)
  }

  @objc fileprivate func profileButtonTapped() {
    delegate?.clipCollectionViewCellProfileButtonTapped(self)
  }

  @objc fileprivate func longPressGestureRecognizerTriggered() {
    delegate?.clipCollectionViewCellLongPressTriggered(self)
  }

  @objc fileprivate func likeButtonTapped() {
    delegate?.clipCollectionViewCellLikeButtonTapped(self)
  }

  fileprivate func setThumbnailScaledDown(_ scaledDown: Bool, animated: Bool) {
    if animated {
      UIView.animate(withDuration: 0.4, animations: {
        self.setThumbnailScaledDown(scaledDown, animated: false)
      }) 
    } else {
      if scaledDown {
        thumbnailImageView.transform = CGAffineTransform(scaleX: 0.857, y: 0.857)
      } else {
        thumbnailImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
      }
    }
  }

  fileprivate func setUserAvatarImageViewBounceConstraints(_ position: Int = 0) {
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

  fileprivate func userAvatarImageViewBeginBouncing() {
    if userAvatarImageViewBounceInProgress { return }
    userAvatarImageViewBounceInProgress = true
    userAvatarImageViewShouldContinueBouncing = true
    _spinUserAvatarImageView()
    _bounceUserAvatarImageView()
  }

  fileprivate func userAvatarImageViewStopBouncingAnimated(_ animated: Bool) {
    userAvatarImageViewShouldContinueBouncing = false
    if !animated {
      userAvatarImageView.layer.removeAllAnimations()
      userAvatarImageView.transform = CGAffineTransform.identity
    }
  }

  fileprivate func _bounceUserAvatarImageView(toTop: Bool = true) {
    let animationCurve = (toTop) ? UIViewAnimationOptions.curveEaseOut : UIViewAnimationOptions.curveEaseIn
    UIView.animateKeyframes(withDuration: userAvatarImageViewBounceDuration / 2,
      delay: 0,
      options: [.calculationModePaced, UIViewKeyframeAnimationOptions(rawValue: animationCurve.rawValue)],
      animations: {
        if toTop {
          UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0) {
            self.setUserAvatarImageViewBounceConstraints(1)
            self.userAvatarImageView.setNeedsLayout()
            self.userAvatarImageView.layoutIfNeeded()
          }
          UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0) {
            self.setUserAvatarImageViewBounceConstraints(2)
            self.userAvatarImageView.setNeedsLayout()
            self.userAvatarImageView.layoutIfNeeded()
          }
        } else {
          UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0) {
            self.setUserAvatarImageViewBounceConstraints(1)
            self.userAvatarImageView.setNeedsLayout()
            self.userAvatarImageView.layoutIfNeeded()
          }
          UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0) {
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

  fileprivate func _spinUserAvatarImageView() {
    let fullRotation = CGFloat(M_PI * -2)
    UIView.animateKeyframes(withDuration: userAvatarImageViewBounceDuration,
      delay: 0,
      options: [.calculationModePaced, UIViewKeyframeAnimationOptions(rawValue: UIViewAnimationOptions.curveLinear.rawValue)],
      animations: {
        UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0) {
          self.userAvatarImageView.transform = CGAffineTransform(rotationAngle: fullRotation * 1/3)
        }
        UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0) {
          self.userAvatarImageView.transform = CGAffineTransform(rotationAngle: fullRotation * 2/3)
        }
        UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0) {
          self.userAvatarImageView.transform = CGAffineTransform(rotationAngle: fullRotation * 3/3)
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
  func clipCollectionViewCellPlayButtonTapped(_ cell: ClipCollectionViewCell)
  func clipCollectionViewCellAddButtonTapped(_ cell: ClipCollectionViewCell)
  func clipCollectionViewCellRetryUploadButtonTapped(_ cell: ClipCollectionViewCell)
  func clipCollectionViewCellProfileButtonTapped(_ cell: ClipCollectionViewCell)
  func clipCollectionViewCellLongPressTriggered(_ cell: ClipCollectionViewCell)
  func clipCollectionViewCellLikeButtonTapped(_ cell: ClipCollectionViewCell)
}

// MARK: - ClipCollectionViewCellState
enum ClipCollectionViewCellState {
  case `default`
  case bookmarked
  case options
  case playingIdle
  case playingActive
  case pendingAcceptance
  case uploading
  case uploadFailed
}
