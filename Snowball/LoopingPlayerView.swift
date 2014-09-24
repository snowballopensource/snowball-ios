//
//  LoopingPlayerView.swift
//  Snowball
//
//  Created by James Martinez on 9/24/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Foundation

import AVFoundation
import UIKit

class LoopingPlayerView: PlayerView {

  func playVideoURL(URL: NSURL) {
    let player = AVQueuePlayer(URL: URL)
    self.player = player
    duplicateAndQueuePlayerItem(player.currentItem)
    player.muted = true
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
    player.play()
  }

  func duplicateAndQueuePlayerItem(playerItem: AVPlayerItem) {
    let player = self.player!
    let duplicatePlayerItem = player.currentItem.copy() as AVPlayerItem
    player.insertItem(duplicatePlayerItem, afterItem: player.items().last as AVPlayerItem)
  }

  // MARK: UIView

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  // MARK: AVPlayerItem

  func playerItemDidReachEnd(notification: NSNotification) {
    duplicateAndQueuePlayerItem(notification.object as AVPlayerItem)
  }
}
