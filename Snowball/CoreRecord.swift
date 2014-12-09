//
//  CoreRecord.swift
//  Snowball
//
//  Created by James Martinez on 12/6/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import CoreData

// Here's where all of my Core Data addons go.

let coreRecordAppName = NSBundle.mainBundle().infoDictionary!["CFBundleName"] as String

struct CoreRecord {
  static func saveWithBlock(block: (context: NSManagedObjectContext) -> ()) {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
      let context = NSManagedObjectContext.privateQueueContext()
      block(context: context)
      context.save(nil)
    }
  }
}