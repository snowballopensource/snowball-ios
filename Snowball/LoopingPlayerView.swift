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

  func playVideoURL(URL: NSURL, muted: Bool = false) {
    let player = AVQueuePlayer(URL: URL)
    self.player = player
    player.actionAtItemEnd = AVPlayerActionAtItemEnd.None
    player.muted = muted
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
    player.play()
  }

  // MARK: UIView

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  // MARK: AVPlayerItem

  func playerItemDidReachEnd(notification: NSNotification) {
    player?.currentItem.seekToTime(kCMTimeZero)
  }
}
