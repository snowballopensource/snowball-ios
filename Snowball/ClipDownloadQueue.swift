//
//  ClipDownloadQueue.swift
//  Snowball
//
//  Created by James Martinez on 12/8/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import Foundation

class ClipDownloadQueue {

  // MARK: - Properties

  private static var sharedQueue = ClipDownloadQueue()

  private var operationQueue: NSOperationQueue = {
    let operationQueue = NSOperationQueue()
    operationQueue.name = "download queue"
    operationQueue.maxConcurrentOperationCount = 1
    operationQueue.qualityOfService = NSQualityOfService.UserInitiated
    return operationQueue
  }()

  // MARK: - Internal

  class func preloadClips(clips: [Clip]) {
    downloadClips(clips, afterEachClipDownloaded: nil)
  }

  class func downloadClips(clips: [Clip], afterEachClipDownloaded: ((clip: Clip, cacheURL: NSURL?, error: NSError?) -> ())?) {
    sharedQueue.downloadClips(clips, afterEachClipDownloaded: afterEachClipDownloaded)
  }

  // MARK: - Private

  private func cancelAllOperations() {
    operationQueue.cancelAllOperations()
  }

  private func addTask(task: () -> ()) {
    let operation = NSBlockOperation()
    operation.addExecutionBlock {
      if operation.cancelled { return }
      task()
    }
    operationQueue.addOperation(operation)
  }

  private func downloadClips(clips: [Clip], afterEachClipDownloaded: ((clip: Clip, cacheURL: NSURL?, error: NSError?) -> ())?) {
    cancelAllOperations()
    for clip in clips {
      addTask {
        if let videoURLString = clip.videoURL, videoURL = NSURL(string: videoURLString) {
          let (data, cacheURL) = Cache.sharedCache.fetchDataAtRemoteURL(videoURL)
          if let _ = data, cacheURL = cacheURL {
            dispatch_async(dispatch_get_main_queue()) {
              afterEachClipDownloaded?(clip: clip, cacheURL: cacheURL, error: nil)
            }
            return
          }
        }
        afterEachClipDownloaded?(clip: clip, cacheURL: nil, error: NSError.snowballErrorWithReason("Error loading clip."))
      }
    }
  }
}