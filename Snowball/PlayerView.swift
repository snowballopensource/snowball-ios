//
//  PlayerView.swift
//  Snowball
//
//  Created by James Martinez on 1/4/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import AVFoundation
import UIKit

class PlayerView: UIView {

  // MARK: Properties

  var player: AVPlayer? {
    get {
      let playerLayer = layer as! AVPlayerLayer
      return playerLayer.player
    }
    set {
      let playerLayer = layer as! AVPlayerLayer
      playerLayer.player = newValue
    }
  }

  // MARK: Initializers

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.darkGrayColor()
  }

  required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  // MARK: UIView

  override class func layerClass() -> AnyClass {
    return AVPlayerLayer.self
  }
}
