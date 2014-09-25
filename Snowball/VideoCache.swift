//
//  VideoCache.swift
//  Snowball
//
//  Created by James Martinez on 9/24/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Foundation
import Haneke

class VideoCache {
  typealias CompletionHandler = (NSURL?, NSError?) -> ()

  class func fetchVideoAtRemoteURL(URL: NSURL, completionHandler: CompletionHandler) {
    let cache = Haneke.sharedDataCache
    let fetcher = NetworkFetcher<NSData>(URL: URL)
    cache.fetchValueForFetcher(fetcher, success: { (data) in
      // Hacky way of getting cache URL from Haneke
      let path = DiskCache("shared-data", capacity: UINT64_MAX).pathForKey(URL.absoluteString!)
      let cacheURL = NSURL(fileURLWithPath: path)
      completionHandler(cacheURL, nil)
      }, failure: { (error) in
        completionHandler(nil, error)
    })
  }
}