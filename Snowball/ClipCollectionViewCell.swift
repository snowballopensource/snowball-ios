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

  let thumbnailImageView = UIImageView()
  let playheadImageView: UIImageView = {
    let imageView = UIImageView(image: UIImage(named: "play"))
    imageView.contentMode = .Center
    imageView.tintColor = UIColor.whiteColor()
    return imageView
  }()
  let playButton = UIButton()

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

    addSubview(playheadImageView)
    constrain(playheadImageView, thumbnailImageView) { playheadImageView, thumbnailImageView in
      playheadImageView.left == thumbnailImageView.left
      playheadImageView.top == thumbnailImageView.top
      playheadImageView.right == thumbnailImageView.right
      playheadImageView.bottom == thumbnailImageView.bottom
    }

    addSubview(playButton)
    constrain(playButton, thumbnailImageView) { (playButton, thumbnailImageView) in
      playButton.left == thumbnailImageView.left
      playButton.top == thumbnailImageView.top
      playButton.right == thumbnailImageView.right
      playButton.height == thumbnailImageView.height
    }
    playButton.addTarget(self, action: "playButtonTapped", forControlEvents: .TouchUpInside)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: UICollectionViewCell

  override func prepareForReuse() {
    thumbnailImageView.image = nil
  }

  // MARK: Internal

  func configueForClip(clip: Clip, state: ClipCollectionViewCellState = .Default) {
    if let thumbnailURLString = clip.thumbnailURL, thumbnailURL = NSURL(string: thumbnailURLString) {
      thumbnailImageView.setImageFromURL(thumbnailURL)
    }

    setState(state, animated: false)
  }

  func setState(state: ClipCollectionViewCellState, animated: Bool) {
    let bookmarked = state == .Bookmarked
//    let options = state == .Options
    let playingIdle = state == .PlayingIdle
    let playingActive = state == .PlayingActive
    let playing = (playingIdle || playingActive)
//    let pendingUpload = state == .PendingUpload
//    let uploading = state == .Uploading
//    let uploadFailed = state == .UploadFailed

    playheadImageView.setHidden(!bookmarked, animated: animated)
    setThumbnailScaledDown(playing, animated: animated)
  }

  // MARK: Private

  @objc private func playButtonTapped() {
    delegate?.clipCollectionViewCellPlayButtonTapped(self)
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
}

// MARK: - ClipCollectionViewCellDelegate
protocol ClipCollectionViewCellDelegate {
  func clipCollectionViewCellPlayButtonTapped(cell: ClipCollectionViewCell)
}

// MARK: - ClipCollectionViewCellState
enum ClipCollectionViewCellState {
  case Default
  case Bookmarked
  case Options
  case PlayingIdle
  case PlayingActive
  case PendingUpload
  case Uploading
  case UploadFailed
}
