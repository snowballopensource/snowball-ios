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

  func playVideoURLs(URLs: [NSURL], completionHandler: CompletionHandler? = nil) {
    super.queueVideoURLs(URLs)
    self.completionHandler = completionHandler
    player?.play()
  }

  // MARK: UIView

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  // MARK: PlayerView

  override func playbackEnded(notification: NSNotification) {
    if let completion = completionHandler {
      completion()
    }
  }
}