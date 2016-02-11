//
//  SingleItemLoopingPlayer.swift
//  Snowball
//
//  Created by James Martinez on 3/3/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import AVFoundation
import Foundation

class SingleItemLoopingPlayer: AVPlayer {

  // MARK: Internal

  func playVideoURL(videoURL: NSURL) {
    let playerItem = AVPlayerItem(URL: videoURL)
    registerPlayerItemForNotifications(playerItem)
    replaceCurrentItemWithPlayerItem(playerItem)
    play()
  }

  func stop() {
    pause()
    replaceCurrentItemWithPlayerItem(nil)
  }

  // MARK: Private

  private func registerPlayerItemForNotifications(playerItem: AVPlayerItem) {
    NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: playerItem, queue: nil) { (notification) in
      if let playerItem = notification.object as? AVPlayerItem {
        playerItem.seekToTime(kCMTimeZero)
        self.play()
      }
    }
  }
}
 