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
    playVideoURLs([URL], completionHandler: completionHandler)
  }

  func playVideoURLs(URLs: [NSURL], completionHandler: CompletionHandler? = nil) {
    var playerItems: [AVPlayerItem] = []
    for URL in URLs {
      let playerItem = AVPlayerItem(URL: URL)
      playerItems.append(playerItem)
    }
    let player = AVQueuePlayer(items: playerItems)
    self.player = player
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "lastPlayerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
    self.completionHandler = completionHandler
    player.play()
  }

  // MARK: UIView

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  // MARK: AVPlayerItem

  func lastPlayerItemDidReachEnd(notification: NSNotification) {
    if let completion = completionHandler {
      completion()
    }
  }
}