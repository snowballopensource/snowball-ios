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
    maxConcurrentOperationCount = 3
  }

  deinit {
    cancelAllOperations()
  }

  // MARK: - Internal

  func preloadClips(clips: [Clip]) {
    // Clips come from server with newest first. Reverse this since timeline is opposite.
    let clips = clips.reverse()

    var thumbnailOperations: [NSOperation] = []
    var videoOperations: [NSOperation] = []
    for clip in clips {
      let thumbnailOperation = NSBlockOperation {
        if let thumbnailURL = clip.thumbnailURL {
          if let thumbnailData = Cache.sharedCache.fetchDataAtURL(thumbnailURL) {
            self.delegate?.thumbnailLoadedForClip(clip, thumbnailData: thumbnailData)
          }
        }
      }
      thumbnailOperations.append(thumbnailOperation)
      let videoOperation = NSBlockOperation {
        if let videoURL = clip.videoURL {
          if let videoData = Cache.sharedCache.fetchDataAtURL(videoURL) {
            println("Video downloaded.")
          }
        }
      }
      videoOperations.append(videoOperation)
    }
    let operations = thumbnailOperations + videoOperations
    addOperations(operations, waitUntilFinished: false)
  }
}

// MARK: - 

protocol ClipPreloadQueueDelegate {
  func thumbnailLoadedForClip(clip: Clip, thumbnailData: NSData)
}