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

  func playVideoURL(_ videoURL: URL) {
    let playerItem = AVPlayerItem(url: videoURL)
    registerPlayerItemForNotifications(playerItem)
    replaceCurrentItem(with: playerItem)
    play()
  }

  func stop() {
    pause()
    replaceCurrentItem(with: nil)
  }

  // MARK: Private

  fileprivate func registerPlayerItemForNotifications(_ playerItem: AVPlayerItem) {
    NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem, queue: nil) { (notification) in
      if let playerItem = notification.object as? AVPlayerItem {
        playerItem.seek(to: kCMTimeZero)
        self.play()
      }
    }
  }
}
 
