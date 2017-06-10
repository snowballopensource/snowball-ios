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

  fileprivate static let sharedInstance = ClipUploadQueue()

  fileprivate var operationQueue: OperationQueue = {
    let operationQueue = OperationQueue()
    operationQueue.name = "upload queue"
    operationQueue.maxConcurrentOperationCount = 1
    return operationQueue
  }()

  // MARK: - Internal

  static func addOperationWithBlock(_ block: @escaping () -> Void) {
    sharedInstance.operationQueue.addOperation(block)
  }
}
