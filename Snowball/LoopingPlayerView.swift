//
//  LoopingPlayerView.swift
//  Snowball
//
//  Created by James Martinez on 9/24/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit

class LoopingPlayerView: PlayerView {

  func playVideoURL(URL: NSURL, muted: Bool = false) {
    queueVideoURL(URL, muted: muted)
    player!.play()
  }

  func queueVideoURL(URL: NSURL, muted: Bool = false) {
    let player = AVQueuePlayer(URL: URL)
    player.actionAtItemEnd = AVPlayerActionAtItemEnd.None
    player.muted = muted
    self.player = player
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "playbackEnded:", name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
  }

  func playbackEnded(notification: NSNotification) {
    player?.currentItem.seekToTime(kCMTimeZero)
  }

  // MARK: UIView

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
}
