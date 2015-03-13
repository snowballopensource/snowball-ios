//
//  ClipPreloadQueue.swift
//  Snowball
//
//  Created by James Martinez on 2/28/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Foundation

class ClipPreloadQueue: NSOperationQueue {

  // MARK: - Properties

  var delegate: ClipPreloadQueueDelegate?

  // MARK: - Initializers

  override init() {
    super.init()
    name = "Clip Preload Queue"
    maxConcurrentOperationCount = 1
    qualityOfService = NSQualityOfService.UserInitiated
  }

  deinit {
    cancelAllOperations()
  }

  // MARK: - Internal

  func preloadClips(clips: [Clip]) {
    var videoOperations: [NSOperation] = []
    for clip in clips {
      let videoOperation = NSBlockOperation {
        if let videoURL = clip.videoURL {
          let (data, cacheURL) = Cache.sharedCache.fetchDataAtURL(videoURL)
          if let data = data {
            if let cacheURL = cacheURL {
              dispatch_async(dispatch_get_main_queue()) {
                self.delegate?.videoReadyForClip(clip, cacheURL: cacheURL)
                return
              }
            }
          }
        }
      }
      videoOperations.append(videoOperation)
    }
    addOperations(videoOperations, waitUntilFinished: false)
  }
}

// MARK: - 

protocol ClipPreloadQueueDelegate {
  func videoReadyForClip(clip: Clip, cacheURL: NSURL)
}