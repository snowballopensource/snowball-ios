//
//  Async.swift
//  Snowball
//
//  Created by James Martinez on 9/18/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Foundation

// TODO: use the real Async when Cocoapods is ready
// https://github.com/duemunk/Async

class Async {
  private class func userInitiatedQueue() -> dispatch_queue_t {
    return dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0)
  }

  class func userInitiated(block: dispatch_block_t) {
    dispatch_async(userInitiatedQueue(), block)
  }
}