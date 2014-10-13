//
//  Player.swift
//  Snowball
//
//  Created by James Martinez on 9/25/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import AVFoundation
import Foundation

protocol PlayerDelegate {
  func playerItemDidPlayToEndTime(playerItem: AVPlayerItem)
  func playerDidFinishPlaying()
}

class Player: AVQueuePlayer {
  var delegate: PlayerDelegate?

  func playerItemDidPlayToEndTime(notification: NSNotification) {
    let playerItem = notification.object! as AVPlayerItem
    delegate?.playerItemDidPlayToEndTime(playerItem)
    let lastPlayerItem = items().last as AVPlayerItem
    if lastPlayerItem == playerItem {
      delegate?.playerDidFinishPlaying()
    }
  }

  // MARK: -

  // MARK: AVQueuePlayer

  override init(items: [AnyObject]!) {
    super.init(items: items)
    for playerItem in items {
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidPlayToEndTime:", name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
    }
  }

  convenience init(reel: Reel) {
    var playerItems = [AVPlayerItem]()
    for clip in reel.playableClips() {
      let clip = clip as Clip
      let playerItem = AVPlayerItem(URL: NSURL(string: clip.videoURL))
      playerItems.append(playerItem)
    }
    self.init(items: playerItems)
  }

  override init(URL: NSURL) {
    super.init(URL: URL)
  }

  override init(playerItem item: AVPlayerItem!) {
    super.init(playerItem: item)
  }

  override init() {
    super.init()
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

}