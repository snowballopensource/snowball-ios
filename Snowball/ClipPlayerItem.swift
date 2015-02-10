//
//  ClipPlayerItem.swift
//  Snowball
//
//  Created by James Martinez on 2/9/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import AVFoundation

class ClipPlayerItem: AVPlayerItem {

  // MARK: - Properties

  var clip: NewClip!

  // MARK: - Initializers 

  convenience init(clip: NewClip) {
    self.init(URL: clip.videoURL!)
    self.clip = clip
  }
}