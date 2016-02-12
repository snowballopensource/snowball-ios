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

  static func addOperationWithBlock(block: () -> Void) {
    sharedInstance.operationQueue.addOperationWithBlock(block)
  }
}