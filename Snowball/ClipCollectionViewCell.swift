//
//  ClipCollectionViewCell.swift
//  Snowball
//
//  Created by James Martinez on 10/29/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import AVFoundation
import Cartography
import UIKit

class ClipCollectionViewCell: UICollectionViewCell {
  private let clipDetailsLabel = UILabel()
  private let recentClipPlayerView = PlayerView()
  private let playbackIndicatorView = UIView()

  func showPlaybackIndicatorView() {
    playbackIndicatorView.hidden = false
  }

  func hidePlaybackIndicatorView() {
    playbackIndicatorView.hidden = true
  }

  // MARK: -

  // MARK: UICollectionViewCell

  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.backgroundColor = UIColor.purpleColor()

    contentView.addSubview(clipDetailsLabel)

    recentClipPlayerView.backgroundColor = UIColor.darkGrayColor()
    contentView.addSubview(recentClipPlayerView)

    playbackIndicatorView.backgroundColor = UIColor.blueColor()
    contentView.addSubview(playbackIndicatorView)
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override class func size() -> CGSize {
    // From the bottom of the camera/player to the bottom of the screen
    // Camera/player is screen width x screen width, so...
    let screenHeight = UIScreen.mainScreen().bounds.height
    let screenWidth = UIScreen.mainScreen().bounds.width
    let cellHeight = screenHeight - screenWidth
    return CGSizeMake(screenWidth/3, cellHeight)
  }

  override func configureForObject(object: AnyObject) {
    let clip = object as Clip
    var clipDetailsString = ""
    if let user = clip.user {
      clipDetailsString = "\(user.username), \(clip.createdAt.shortTimeSinceString())"
    }
    clipDetailsLabel.text = clipDetailsString
    let clipVideoURL = NSURL(string: clip.videoURL)
    self.recentClipPlayerView.player = Player(videoURL: clipVideoURL!)

    hidePlaybackIndicatorView()
  }

  // MARK: UIView

  override func layoutSubviews() {
    super.layoutSubviews()

    let margin: Float = 13.0

    layout(recentClipPlayerView) { (recentClipPlayerView) in
      let sideLength = Float(ClipCollectionViewCell.size().width)
      recentClipPlayerView.top == recentClipPlayerView.superview!.top
      recentClipPlayerView.left == recentClipPlayerView.superview!.left
      recentClipPlayerView.height == sideLength
      recentClipPlayerView.width == sideLength
    }

    layout(clipDetailsLabel, recentClipPlayerView) { (clipDetailsLabel, recentClipPlayerView) in
      clipDetailsLabel.top == recentClipPlayerView.bottom + margin
      clipDetailsLabel.left == recentClipPlayerView.left + margin
      clipDetailsLabel.right == recentClipPlayerView.right - margin
    }

    playbackIndicatorView.frame = recentClipPlayerView.frame
  }
}