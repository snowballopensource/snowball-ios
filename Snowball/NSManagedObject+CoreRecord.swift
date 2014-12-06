//
//  NSManagedObject+CoreRecord.swift
//  Snowball
//
//  Created by James Martinez on 12/6/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import CoreData

extension NSManagedObject {

  // MARK: - General

  class func entityName() -> String {
    return NSStringFromClass(self)
  }

  // MARK: - Object Creation

  class func newInDefaultContext() -> Self {
    return NSEntityDescription.insertNewObjectForEntityForName(entityName(), inManagedObjectContext: CoreDataStack.defaultStack.managedObjectContext) as NSManagedObject
  }
}