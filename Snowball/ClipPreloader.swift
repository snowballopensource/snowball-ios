//
//  ClipPreloader.swift
//  Snowball
//
//  Created by James Martinez on 8/19/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Foundation

/*
  The goal of this class is to preload clips for playback by reshuffling preload operations.
  This was not achieved the correct way.
  Goal: [0, 1, 2, 3, 4, 5], press play on 3, loads 3, 4, 5, 0, 1, 2
  This happens, but if you stop the clip from playing and then press play on 0,
  the operation queue will look like 0, 3, 4, 5, 1, 2, 1, 2, 3, 4, 5
  since the operations are not cancelled. Cancelling would not work with the current API laid
  out below, but could possibly be done better with a minor refactor of this class.
*/

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

  class func load(clip: Clip, completion: ((clip: Clip, cacheURL: NSURL?, error: NSError?) -> Void)?) {
    load(clip, priority: NSOperationQueuePriority.VeryHigh, completion: completion)
  }

  class func preloadTimeline(timeline: Timeline, withFirstClip clip: Clip?) {
    if let clip = clip {
      let offset = timeline.indexOfClip(clip)
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

  private class func load(clip: Clip, priority: NSOperationQueuePriority, completion: ((clip: Clip, cacheURL: NSURL?, error: NSError?) -> Void)?) {
    let operation = NSBlockOperation()
    operation.queuePriority = priority
    operation.addExecutionBlock {
      if let videoURLString = clip.videoURL, videoURL = NSURL(string: videoURLString) {
        let (data, cacheURL) = Cache.sharedCache.fetchDataAtRemoteURL(videoURL)
        if let data = data, cacheURL = cacheURL {
          dispatch_async(dispatch_get_main_queue()) {
            completion?(clip: clip, cacheURL: cacheURL, error: nil)
          }
          return
        }
      }
      completion?(clip: clip, cacheURL: nil, error: NSError(domain: "", code: 0, userInfo: nil))
    }
    sharedPreloader.addOperation(operation)
  }
}