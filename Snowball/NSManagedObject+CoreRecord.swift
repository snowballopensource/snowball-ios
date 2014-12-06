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
    return NSStringFromClass(self).stringByReplacingOccurrencesOfString("\(appName).", withString: "", options: nil, range: nil)
  }

  // MARK: - Object Creation

  class func newInDefaultContext() -> NSManagedObject {
    return NSEntityDescription.insertNewObjectForEntityForName(entityName(), inManagedObjectContext: CoreDataStack.defaultStack.managedObjectContext) as NSManagedObject
  }

  // MARK: - Finders

  // TODO: should this be in a background context?
  // TODO: should I be calling .executeFetchRequest inside of context.performBlockAndWait?

  class func findAll(predicate: NSPredicate? = nil) -> [NSManagedObject] {
    let context = CoreDataStack.defaultStack.managedObjectContext
    let entityDescription = NSEntityDescription.entityForName(entityName(), inManagedObjectContext: context)
    let fetchRequest = NSFetchRequest(entityName: entityName())
    fetchRequest.predicate = predicate
    fetchRequest.entity = entityDescription
    var results = [NSManagedObject]()
    var error: NSError?
    results = context.executeFetchRequest(fetchRequest, error: &error)! as [NSManagedObject]
    return results
  }
}