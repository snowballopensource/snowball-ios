//
//  PlayerView.swift
//  Snowball
//
//  Created by James Martinez on 9/24/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import AVFoundation
import UIKit

class PlayerView: UIView {

  var player: AVQueuePlayer? {
    get {
      let playerLayer = self.layer as AVPlayerLayer
      return playerLayer.player as? AVQueuePlayer
    }
    set {
      let playerLayer = self.layer as AVPlayerLayer
      playerLayer.player = newValue
    }
  }

  // MARK: UIView

  override class func layerClass() -> AnyClass {
    return AVPlayerLayer.self
  }
  
}
