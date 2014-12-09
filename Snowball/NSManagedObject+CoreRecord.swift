//
//  NSManagedObject+CoreRecord.swift
//  Snowball
//
//  Created by James Martinez on 12/6/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import CoreData

extension NSManagedObject {

  // MARK: - Misc

  class func entityName() -> String {
    return NSStringFromClass(self).stringByReplacingOccurrencesOfString("\(coreRecordAppName).", withString: "", options: nil, range: nil)
  }

  // MARK: - Object Creation

  class func newInContext(context: NSManagedObjectContext) -> NSManagedObject {
    return NSEntityDescription.insertNewObjectForEntityForName(entityName(), inManagedObjectContext: context) as NSManagedObject
  }

  // MARK: - Savers

  func save() -> Bool {
    return managedObjectContext!.save(nil)
  }

  // MARK: - Finders

  // TODO: should this be in a background context?
  // TODO: should I be calling .executeFetchRequest inside of context.performBlockAndWait?

  class func findAll(predicate: NSPredicate? = nil, context: NSManagedObjectContext) -> [NSManagedObject] {
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