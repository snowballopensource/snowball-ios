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

  convenience init?(clip: Clip) {
    guard
      let videoURL = clip.videoURL,
      let url = URL(string: videoURL),
      var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
    else { return nil }
    components.scheme = CachedAssetResourceLoader.handledScheme
    guard let modifiedURL = components.url else { return nil }
    let asset = AVURLAsset(url: modifiedURL)
    asset.resourceLoader.setDelegate(CachedAssetResourceLoader.sharedInstance, queue: DispatchQueue.main)
    self.init(asset: asset)
    self.clip = clip
  }
}
