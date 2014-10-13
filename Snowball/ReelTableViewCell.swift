//
//  ReelTableViewCell.swift
//  Snowball
//
//  Created by James Martinez on 9/24/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import AVFoundation
import Cartography
import UIKit

class ReelTableViewCell: UITableViewCell {
  private let titleLabel = UILabel()
  private let participantsTitleLabel = UILabel()
  private let recentClipPlayerView = PlayerView()
  private let playbackIndicatorView = UIView()

  func showPlaybackIndicatorView() {
    playbackIndicatorView.hidden = false
    pausePlayback()
  }

  func hidePlaybackIndicatorView() {
    playbackIndicatorView.hidden = true
    startPlayback()
  }

  func startPlayback() {
    recentClipPlayerView.player?.play()
  }

  func pausePlayback() {
    recentClipPlayerView.player?.pause()
  }

  // MARK: -

  // MARK: UITableViewCell

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    selectionStyle = UITableViewCellSelectionStyle.None
    contentView.backgroundColor = UIColor.whiteColor()
    contentView.addSubview(titleLabel)
    contentView.addSubview(participantsTitleLabel)
    recentClipPlayerView.backgroundColor = UIColor.darkGrayColor()
    contentView.addSubview(recentClipPlayerView)
    playbackIndicatorView.backgroundColor = UIColor.blueColor()
    contentView.addSubview(playbackIndicatorView)
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override class func height() -> CGFloat {
    return UIScreen.mainScreen().bounds.width/2
  }

  override func configureForObject(object: AnyObject) {
    let reel = object as Reel
    titleLabel.text = reel.title
    participantsTitleLabel.text = reel.participantsTitle
    hidePlaybackIndicatorView()
    if let recentClip = reel.recentClip() {
      let recentClipVideoURL = NSURL(string: recentClip.videoURL)
      let player = Player(videoURL: recentClipVideoURL)
      player.loop = true
      player.muted = true
      self.recentClipPlayerView.player = player
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
    layout(recentClipPlayerView) { (recentClipPlayerView) in
      let sideLength = Float(ReelTableViewCell.height())
      recentClipPlayerView.top == recentClipPlayerView.superview!.top
      recentClipPlayerView.right == recentClipPlayerView.superview!.right
      recentClipPlayerView.height == sideLength
      recentClipPlayerView.width == sideLength
    }
    playbackIndicatorView.frame = recentClipPlayerView.frame
  }
}