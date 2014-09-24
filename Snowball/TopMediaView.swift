//
//  TopMediaView.swift
//  Snowball
//
//  Created by James Martinez on 9/24/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

class TopMediaView: UIView {
  let playerView = DisappearingPlayerView()
  var cameraView: CameraView? {
    didSet {
      self.insertFullViewSubview(cameraView!, belowSubview: playerView)
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.addFullViewSubview(playerView)
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  convenience override init() {
    self.init(frame: CGRectZero)
  }
}