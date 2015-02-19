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

  var clip: Clip!

  // MARK: - Initializers 

  convenience init(clip: Clip) {
    self.init(asset: AVURLAsset(URL: clip.videoURL!, options: nil), automaticallyLoadedAssetKeys: ["tracks", "playable"])
    self.clip = clip
  }

  convenience init(clip: Clip, asset: AVAsset) {
    self.init(asset: asset)
    self.clip = clip
  }
}