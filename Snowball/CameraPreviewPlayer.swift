//
//  CameraPreviewPlayer.swift
//  Snowball
//
//  Created by James Martinez on 3/3/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import AVFoundation

class CameraPreviewPlayer: AVPlayer {

  // MARK: - Internal

  func playVideo(videoURL: NSURL) {
    let playerItem = AVPlayerItem(URL: videoURL)
    registerPlayerItemForNotifications(playerItem)
    replaceCurrentItemWithPlayerItem(playerItem)
    play()
  }

  func stop() {
    pause()
    replaceCurrentItemWithPlayerItem(nil)
  }

  // MARK: - Private

  private func registerPlayerItemForNotifications(playerItem: AVPlayerItem) {
    NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: playerItem, queue: nil) { (notification) in
      let playerItem = notification.object as AVPlayerItem
      playerItem.seekToTime(kCMTimeZero)
      self.play()
    }
  }
}
