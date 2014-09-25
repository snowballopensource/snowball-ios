//
//  ReelCollectionViewCell.swift
//  Snowball
//
//  Created by James Martinez on 9/24/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import AVFoundation
import Cartography
import UIKit

class ReelCollectionViewCell: UICollectionViewCell {
  private let titleLabel = UILabel()
  private let participantsTitleLabel = UILabel()
  private let recentClipLoopingPlayerView = LoopingPlayerView()
  private let playbackIndicatorView = UIView()

  class var size: CGSize {
    get {
      let sideLength = UIScreen.mainScreen().bounds.width/2
      return CGSizeMake(sideLength, sideLength)
    }
  }

  func showPlaybackIndicatorView() {
    playbackIndicatorView.hidden = false
  }

  func hidePlaybackIndicatorView() {
    playbackIndicatorView.hidden = true
  }

  // MARK: -

  // MARK: UITableViewCell

  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.backgroundColor = UIColor.whiteColor()
    contentView.addSubview(titleLabel)
    contentView.addSubview(participantsTitleLabel)
    recentClipLoopingPlayerView.backgroundColor = UIColor.darkGrayColor()
    contentView.addSubview(recentClipLoopingPlayerView)
    playbackIndicatorView.backgroundColor = UIColor.blueColor()
    contentView.addSubview(playbackIndicatorView)
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func configureForObject(object: AnyObject) {
    let reel = object as Reel
    titleLabel.text = reel.title
    participantsTitleLabel.text = reel.participantsTitle
    hidePlaybackIndicatorView()
    if let recentClip = reel.recentClip() {
      let recentClipVideoURL = NSURL(string: recentClip.videoURL)
      VideoCache.fetchVideoAtRemoteURL(recentClipVideoURL) { (URL, error) in
        if let videoURL = URL {
          self.recentClipLoopingPlayerView.playVideoURL(videoURL, muted: true)
        }
      }
    }
  }

  // MARK: UIView

  override func layoutSubviews() {
    super.layoutSubviews()

    let margin: Float = 13.0

    layout(titleLabel) { (titleLabel) in
      titleLabel.top == titleLabel.superview!.top + margin
      titleLabel.left == titleLabel.superview!.left + margin
      titleLabel.right == titleLabel.superview!.right - margin
    }

    layout(participantsTitleLabel) { (participantsTitleLabel) in
      participantsTitleLabel.bottom == participantsTitleLabel.superview!.bottom - margin
      participantsTitleLabel.left == participantsTitleLabel.superview!.left + margin
      participantsTitleLabel.right == participantsTitleLabel.superview!.right - margin
    }

    layout(recentClipLoopingPlayerView) { (recentClipLoopingPlayerView) in
      let sideLength: Float = 64.0
      recentClipLoopingPlayerView.centerY == recentClipLoopingPlayerView.superview!.centerY
      recentClipLoopingPlayerView.left == recentClipLoopingPlayerView.superview!.left + margin
      recentClipLoopingPlayerView.width == sideLength
      recentClipLoopingPlayerView.height == sideLength
    }
    playbackIndicatorView.frame = recentClipLoopingPlayerView.frame
  }
}