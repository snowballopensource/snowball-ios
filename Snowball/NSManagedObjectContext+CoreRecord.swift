//
//  NSManagedObjectContext+CoreRecord.swift
//  Snowball
//
//  Created by James Martinez on 12/8/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {

  // MARK: - Convenience Accessors

  class func mainQueueContext() -> NSManagedObjectContext {
    return CoreDataStack.defaultStack.mainQueueManagedObjectContext
  }

}