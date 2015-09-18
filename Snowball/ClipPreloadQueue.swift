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
      let videoOperation = NSBlockOperation()
      videoOperation.addExecutionBlock {
        if let videoURLString = clip.videoURL, videoURL = NSURL(string: videoURLString) {
          let (data, cacheURL) = Cache.sharedCache.fetchDataAtRemoteURL(videoURL)
          if let _ = data {
            if let cacheURL = cacheURL {
              dispatch_async(dispatch_get_main_queue()) {
                if !videoOperation.cancelled {
                  self.delegate?.videoReadyForClip(clip, cacheURL: cacheURL)
                }
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