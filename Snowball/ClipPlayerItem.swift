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
    let URLComponents = NSURLComponents(URL: URL, resolvingAgainstBaseURL: true)!
    URLComponents.scheme = CachedAssetResourceLoader.handledScheme
    let asset = AVURLAsset(URL: URLComponents.URL!)
    asset.resourceLoader.setDelegate(CachedAssetResourceLoader.sharedInstance, queue: dispatch_get_main_queue())
    self.init(asset: asset)
    self.clip = clip
  }
}