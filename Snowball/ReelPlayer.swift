//
//  ReelPlayer.swift
//  Snowball
//
//  Created by James Martinez on 9/25/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import AVFoundation
import Foundation

protocol ReelPlayerDelegate {
  func playerItemDidPlayToEndTime(playerItem: AVPlayerItem)
  func playerDidFinishPlaying()
}

class ReelPlayer: AVQueuePlayer {
  var delegate: ReelPlayerDelegate?

  override init(items: [AnyObject]!) {
    super.init(items: items)
  }

  convenience init(reel: Reel) {
    // TODO: only watch unwatched clips
    var playerItems: [AVPlayerItem] = []
    for clip in reel.clips() {
      let clip = clip as Clip
      let playerItem = AVPlayerItem(URL: NSURL(string: clip.videoURL))
      playerItems.append(playerItem)
    }
    self.init(items: playerItems)
    for playerItem in playerItems {
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidPlayToEndTime:", name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
    }
  }

  override init() {
    super.init()
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  func playerItemDidPlayToEndTime(notification: NSNotification) {
    let playerItem = notification.object! as AVPlayerItem
    delegate?.playerItemDidPlayToEndTime(playerItem)
    let lastPlayerItem = items().last as AVPlayerItem
    if lastPlayerItem == playerItem {
      delegate?.playerDidFinishPlaying()
    }
  }
}