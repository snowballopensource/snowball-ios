//
//  ClipUploadQueue.swift
//  Snowball
//
//  Created by James Martinez on 2/12/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Foundation

class ClipUploadQueue {

  // MARK: Properties

  private static let sharedInstance = ClipUploadQueue()

  private var operationQueue: NSOperationQueue = {
    let operationQueue = NSOperationQueue()
    operationQueue.name = "upload queue"
    operationQueue.maxConcurrentOperationCount = 1
    return operationQueue
  }()

  // MARK: - Internal

  static func queueClipForUploading(clip: Clip) {
    // TODO: Upload Clip
    print("TODO: Upload Clip")
    sharedInstance.operationQueue.addOperationWithBlock {
      print("Upload operation completed")
    }
  }
}