//
//  PlayerView.swift
//  Snowball
//
//  Created by James Martinez on 8/8/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import AVFoundation
import UIKit

class PlayerView: UIView {
  var player: AVPlayer? {
    get {
      return (layer as? AVPlayerLayer)?.player
    }
    set {
      (layer as? AVPlayerLayer)?.player = newValue
    }
  }

  override class func layerClass() -> AnyClass {
    return AVPlayerLayer.self
  }
}