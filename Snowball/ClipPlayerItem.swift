//
//  ClipPlayerItem.swift
//  Snowball
//
//  Created by James Martinez on 1/5/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import AVFoundation

class ClipPlayerItem: AVPlayerItem {

  // MARK: Properties

  var clip: Clip!

  // MARK: Initializers

  convenience init(URL: NSURL, clip: Clip) {
    self.init(URL: URL)
    self.clip = clip
  }
}