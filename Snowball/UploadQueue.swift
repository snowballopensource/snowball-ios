//
//  UploadQueue.swift
//  Snowball
//
//  Created by James Martinez on 2/24/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Foundation

class UploadQueue {

  // MARK: - Properties

  class var sharedQueue: UploadQueue {
    struct Singleton {
      static let sharedQueue = UploadQueue()
    }
    return Singleton.sharedQueue
  }

  private var operationQueue: NSOperationQueue = {
    let operationQueue = NSOperationQueue()
    operationQueue.name = "upload queue"
    operationQueue.maxConcurrentOperationCount = 1
    return operationQueue
  }()

  // MARK: - Internal

  func addTask(task: () -> ()) {
    operationQueue.addOperationWithBlock(task)
  }
}