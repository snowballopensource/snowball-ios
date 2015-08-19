//
//  ClipPreloader.swift
//  Snowball
//
//  Created by James Martinez on 8/19/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Foundation

class ClipPreloader: NSOperationQueue {

  // MARK: - Properties

  static let sharedPreloader = ClipPreloader()

  // MARK: - Initializers

  override init() {
    super.init()
    name = "Clip Preloader"
    maxConcurrentOperationCount = 1
    qualityOfService = NSQualityOfService.UserInitiated
  }

  // MARK: - Internal

  class func load(clip: Clip, completion: ((cacheURL: NSURL?, error: NSError?) -> Void)?) {
    sharedPreloader.addOperationWithBlock { () -> Void in
      if let videoURLString = clip.videoURL, videoURL = NSURL(string: videoURLString) {
        let (data, cacheURL) = Cache.sharedCache.fetchDataAtURL(videoURL)
        if let data = data, cacheURL = cacheURL {
          dispatch_async(dispatch_get_main_queue()) {
            completion?(cacheURL: cacheURL, error: nil)
          }
          return
        }
      }
      completion?(cacheURL: nil, error: NSError())
    }
  }

  class func preloadTimeline(timeline: Timeline) {
    for clip in timeline.clips {
      load(clip, completion: nil)
    }
  }
}