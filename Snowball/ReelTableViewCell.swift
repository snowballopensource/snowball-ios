//
//  ReelTableViewCell.swift
//  Snowball
//
//  Created by James Martinez on 9/22/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class ReelTableViewCell: UITableViewCell {
  private let titleLabel = UILabel()
  private let participantsTitleLabel = UILabel()
  private let lastClipThumbnailImageView = UIImageView()
  private let playbackIndicatorView = UIImageView()

  // Can't use class let yet, so doing a computed property to hold over
  // class let height: CGFloat = UIScreen.mainScreen().bounds.width/2
  class var height: CGFloat {
    get {
      return UIScreen.mainScreen().bounds.width/2
    }
  }

  func beginPlayback(url: NSURL) {
    self.playbackIndicatorView.hidden = false
  }

  // MARK: -

  // MARK: UITableViewCell

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(titleLabel)
    contentView.addSubview(participantsTitleLabel)
    lastClipThumbnailImageView.backgroundColor = UIColor.darkGrayColor()
    contentView.addSubview(lastClipThumbnailImageView)
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
    lastClipThumbnailImageView.image = nil
    if let lastClip = reel.clips.lastObject() as? Clip {
      lastClipThumbnailImageView.setImageFromURL(NSURL(string: lastClip.thumbnailURL))
    }
  }

  // MARK: UIView

  override func layoutSubviews() {
    super.layoutSubviews()

    let margin: Float = 20.0

    layout(lastClipThumbnailImageView) { (lastClipThumbnailImageView) in
      lastClipThumbnailImageView.top == lastClipThumbnailImageView.superview!.top
      lastClipThumbnailImageView.right == lastClipThumbnailImageView.superview!.right
      lastClipThumbnailImageView.width == lastClipThumbnailImageView.superview!.height
      lastClipThumbnailImageView.height == lastClipThumbnailImageView.superview!.height
    }
    layout(titleLabel, lastClipThumbnailImageView) { (titleLabel, lastClipThumbnailImageView) in
      titleLabel.top == titleLabel.superview!.top + margin
      titleLabel.left == titleLabel.superview!.left + margin
      titleLabel.right == lastClipThumbnailImageView.left - margin
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