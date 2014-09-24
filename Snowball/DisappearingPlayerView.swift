//
//  DisappearingPlayerView.swift
//  Snowball
//
//  Created by James Martinez on 9/24/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import AVFoundation
import UIKit

class DisappearingPlayerView: PlayerView {
  typealias CompletionHandler = () -> ()
  var completionHandler: CompletionHandler?

  func playVideoURL(URL: NSURL, completionHandler: CompletionHandler? = nil) {
    let player = AVQueuePlayer(URL: URL)
    self.player = player
    player.muted = true
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
    self.completionHandler = completionHandler
    player.play()
  }

  // MARK: UIView

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  // MARK: AVPlayerItem

  func playerItemDidReachEnd(notification: NSNotification) {
    if let completion = completionHandler {
      completion()
    }
  }
}