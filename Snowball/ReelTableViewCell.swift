//
//  ReelTableViewCell.swift
//  Snowball
//
//  Created by James Martinez on 9/22/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import AVFoundation
import Cartography
import UIKit

class ReelTableViewCell: UITableViewCell {
  private let titleLabel = UILabel()
  private let participantsTitleLabel = UILabel()
  private let recentClipLoopingPlayerView = LoopingPlayerView()
  private let playbackIndicatorView = UIImageView()

  // Can't use class let yet, so doing a computed property to hold over
  // class let height: CGFloat = UIScreen.mainScreen().bounds.width/2
  class var height: CGFloat {
    get {
      return 65.0
    }
  }

  // MARK: -

  // MARK: UITableViewCell

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(titleLabel)
    contentView.addSubview(participantsTitleLabel)
    recentClipLoopingPlayerView.backgroundColor = UIColor.darkGrayColor()
    contentView.addSubview(recentClipLoopingPlayerView)
    playbackIndicatorView.backgroundColor = UIColor.blueColor()
    playbackIndicatorView.hidden = true
    contentView.addSubview(playbackIndicatorView)
  }

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  override func configureForObject(object: AnyObject) {
    let reel = object as Reel
    titleLabel.text = reel.title
    participantsTitleLabel.text = reel.participantsTitle
    if let recentClip = reel.recentClip() {
      println("playing...")
      recentClipLoopingPlayerView.playVideoURL(NSURL(string: recentClip.videoURL))
    }
  }

  // MARK: UIView

  override func layoutSubviews() {
    super.layoutSubviews()

    let margin: Float = 10.0

    layout(recentClipLoopingPlayerView) { (recentClipLoopingPlayerView) in
      recentClipLoopingPlayerView.top == recentClipLoopingPlayerView.superview!.top
      recentClipLoopingPlayerView.right == recentClipLoopingPlayerView.superview!.right
      recentClipLoopingPlayerView.width == recentClipLoopingPlayerView.superview!.height
      recentClipLoopingPlayerView.height == recentClipLoopingPlayerView.superview!.height
    }
    layout(titleLabel, recentClipLoopingPlayerView) { (titleLabel, recentClipLoopingPlayerView) in
      titleLabel.top == titleLabel.superview!.top + margin
      titleLabel.left == titleLabel.superview!.left + margin
      titleLabel.right == recentClipLoopingPlayerView.left - margin
    }
    layout(participantsTitleLabel, titleLabel) { (participantsTitleLabel, titleLabel) in
      participantsTitleLabel.bottom == participantsTitleLabel.superview!.bottom - margin
      participantsTitleLabel.left == titleLabel.left
      participantsTitleLabel.right == titleLabel.right
    }
    layout(playbackIndicatorView, titleLabel, participantsTitleLabel) { (playbackIndicatorView, titleLabel, participantsTitleLabel) in
      playbackIndicatorView.top == titleLabel.bottom
      playbackIndicatorView.bottom == participantsTitleLabel.top
      playbackIndicatorView.left == titleLabel.left
      playbackIndicatorView.right == titleLabel.right
    }
  }
}