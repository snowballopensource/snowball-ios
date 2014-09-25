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
    queueVideoURL(URL, muted: muted)
    player!.play()
  }

  func queueVideoURL(URL: NSURL, muted: Bool = false) {
    super.queueVideoURLs([URL])
    player?.actionAtItemEnd = AVPlayerActionAtItemEnd.None
    player?.muted = muted
  }

  // MARK: UIView

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  // MARK: PlayerView

  override func playbackEnded(notification: NSNotification) {
    player?.currentItem.seekToTime(kCMTimeZero)
  }
}
