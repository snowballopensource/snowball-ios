//
//  AVURLAsset+Cache.swift
//  Snowball
//
//  Created by James Martinez on 10/13/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import AVFoundation
import Foundation
import Haneke

extension AVURLAsset {
  typealias CompletionHandler = (AVURLAsset?, NSError?) -> ()

  class func createAssetFromURL(URL: NSURL, completionHandler: CompletionHandler? = nil) {
    let cache = Haneke.sharedDataCache
    cache.fetch(URL: URL).onSuccess { (data) in
      // Hacky way of getting cache URL from Haneke
      let path = DiskCache(name: "shared-data", capacity: UINT64_MAX).pathForKey(URL.absoluteString!)
      let cacheURL = NSURL(fileURLWithPath: path)
      if let completion = completionHandler { completion(AVURLAsset(URL: cacheURL, options: nil), nil) }
      }.onFailure { (error) in
        if let completion = completionHandler { completion(nil, error) }
    }
  }

//  func setVideoFromURL(URL: NSURL, completionHandler: CompletionHandler? = nil) {
//
//  }
}