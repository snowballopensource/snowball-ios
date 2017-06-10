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
    guard let videoURL = clip.videoURL else { return nil }
    guard let URL = URL(string: videoURL) else { return nil }
    guard let URLComponents = URLComponents(url: URL, resolvingAgainstBaseURL: true) else { return nil }
    URLComponents.scheme = CachedAssetResourceLoader.handledScheme
    guard let modifiedURL = URLComponents.url else { return nil }
    let asset = AVURLAsset(url: modifiedURL)
    asset.resourceLoader.setDelegate(CachedAssetResourceLoader.sharedInstance, queue: DispatchQueue.main)
    self.init(asset: asset)
    self.clip = clip
  }
}
