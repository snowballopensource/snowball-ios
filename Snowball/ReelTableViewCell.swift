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
  private let recentClipPlayerView = PlayerView()
  private let playbackIndicatorView = UIImageView()

  // Can't use class let yet, so doing a computed property to hold over
  // class let height: CGFloat = UIScreen.mainScreen().bounds.width/2
  class var height: CGFloat {
    get {
      return UIScreen.mainScreen().bounds.width/2
    }
  }

  func playVideoURL(URL: NSURL) {
    let player = AVQueuePlayer(URL: URL)
    self.recentClipPlayerView.player = player
    duplicateAndQueuePlayerItem(player.currentItem)
    player.muted = true
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
    player.play()
  }

  func duplicateAndQueuePlayerItem(playerItem: AVPlayerItem) {
    let player = recentClipPlayerView.player!
    let duplicatePlayerItem = player.currentItem.copy() as AVPlayerItem
    player.insertItem(duplicatePlayerItem, afterItem: player.items().last as AVPlayerItem)
  }

  // MARK: -

  // MARK: UITableViewCell

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(titleLabel)
    contentView.addSubview(participantsTitleLabel)
    recentClipPlayerView.backgroundColor = UIColor.darkGrayColor()
    contentView.addSubview(recentClipPlayerView)
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
      playVideoURL(NSURL(string: recentClip.videoURL))
    }
  }

  // MARK: UIView

  override func layoutSubviews() {
    super.layoutSubviews()

    let margin: Float = 20.0

    layout(recentClipPlayerView) { (recentClipPlayerView) in
      recentClipPlayerView.top == recentClipPlayerView.superview!.top
      recentClipPlayerView.right == recentClipPlayerView.superview!.right
      recentClipPlayerView.width == recentClipPlayerView.superview!.height
      recentClipPlayerView.height == recentClipPlayerView.superview!.height
    }
    layout(titleLabel, recentClipPlayerView) { (titleLabel, recentClipPlayerView) in
      titleLabel.top == titleLabel.superview!.top + margin
      titleLabel.left == titleLabel.superview!.left + margin
      titleLabel.right == recentClipPlayerView.left - margin
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

  // MARK: AVPlayerItem

  func playerItemDidReachEnd(notification: NSNotification) {
    duplicateAndQueuePlayerItem(notification.object as AVPlayerItem)
  }

}