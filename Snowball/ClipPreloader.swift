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
    load(clip, priority: NSOperationQueuePriority.VeryHigh, completion: completion)
  }

  class func preloadTimeline(timeline: Timeline, withFirstClip clip: Clip?) {
    if let clip = clip {
      var offset = timeline.indexOfClip(clip)
      if let offset = offset {
        let clipsCount = timeline.clips.count
        for var i = 0; i < clipsCount; i++ {
          let offsetIndex = (i + offset) % clipsCount
          load(timeline.clips[offsetIndex], priority: NSOperationQueuePriority.Normal, completion: nil)
        }
      }
    } else if let firstClip = timeline.clips.first {
      for clip in timeline.clips {
        load(clip, priority: NSOperationQueuePriority.Normal, completion: nil)
      }
    }
  }

  // MARK: - Private

  private class func load(clip: Clip, priority: NSOperationQueuePriority, completion: ((cacheURL: NSURL?, error: NSError?) -> Void)?) {
    let operation = NSBlockOperation()
    operation.queuePriority = priority
    operation.addExecutionBlock {
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
    sharedPreloader.addOperation(operation)
  }
}