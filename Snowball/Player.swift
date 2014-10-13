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
  var loop = false
  var delegate: PlayerDelegate?

  func playerItemDidPlayToEndTime(notification: NSNotification) {
    let playerItem = notification.object! as AVPlayerItem
    delegate?.playerItemDidPlayToEndTime(playerItem)
    if loop {
      playerItem.seekToTime(kCMTimeZero)
    } else {
      let lastPlayerItem = items().last as AVPlayerItem
      if lastPlayerItem == playerItem {
        delegate?.playerDidFinishPlaying()
      }
    }
  }

  private func setupPlayerIssueHandling() {
    // Handle buffering issues
    bk_addObserverForKeyPath("rate") { (_) in
      println("rate change to: \(self.rate)")
      if self.rate == 0 && CMTimeGetSeconds(self.currentItem.currentTime()) != CMTimeGetSeconds(self.currentItem.duration) {
        self.currentItem.bk_addObserverForKeyPath("playbackLikelyToKeepUp") { (_) in
          println("playbackLikelyToKeepUp change to: \(self.currentItem.playbackLikelyToKeepUp)")
          if self.currentItem.playbackLikelyToKeepUp {
            self.play()
          }
        }
      }
    }
  }

  // MARK: -

  // MARK: AVQueuePlayer

  override init(items: [AnyObject]!) {
    super.init(items: items)
    actionAtItemEnd = AVPlayerActionAtItemEnd.None
    setupPlayerIssueHandling()
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

  convenience init(videoURL: NSURL) {
    let playerItem = AVPlayerItem(URL: videoURL)
    self.init(items: [playerItem])
  }

  override init() {
    super.init()
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

}