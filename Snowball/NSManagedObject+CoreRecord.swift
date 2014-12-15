//
//  NSManagedObject+CoreRecord.swift
//  Snowball
//
//  Created by James Martinez on 12/6/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import CoreData

extension NSManagedObject {

  // MARK: - Base

  class func entityName() -> String {
    return NSStringFromClass(self).stringByReplacingOccurrencesOfString("\(coreRecordAppName).", withString: "", options: nil, range: nil)
  }

  class func primaryKey() -> String {
    return "id"
  }

  // MARK: - Object Creation

  class func newEntity(attributes: AnyObject? = nil, context: NSManagedObjectContext = NSManagedObjectContext.mainQueueContext()) -> NSManagedObject {
    let object = NSEntityDescription.insertNewObjectForEntityForName(entityName(), inManagedObjectContext: context) as NSManagedObject
    if attributes != nil {
      object.assign(attributes!)
    }
    return object
  }

  // MARK: - Attribute Assignment

  func assign(attributes: AnyObject) {}

  // MARK: - Savers

  func save() -> Bool {
    return managedObjectContext!.save(nil)
  }

  // MARK: - Finders

  class func find(primaryKey: String, context: NSManagedObjectContext = NSManagedObjectContext.mainQueueContext()) -> NSManagedObject? {
    return findAll(predicate: NSPredicate(format: "%K == %@", self.primaryKey(), primaryKey), context: context).first
  }

  class func findOrInitialize(primaryKey: String, context: NSManagedObjectContext = NSManagedObjectContext.mainQueueContext()) -> NSManagedObject {
    return find(primaryKey, context: context) ?? newEntity(context: context)
  }

  class func findAll(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, context: NSManagedObjectContext = NSManagedObjectContext.mainQueueContext()) -> [NSManagedObject] {
    let entityDescription = NSEntityDescription.entityForName(entityName(), inManagedObjectContext: context)
    let fetchRequest = NSFetchRequest(entityName: entityName())
    fetchRequest.predicate = predicate
    fetchRequest.entity = entityDescription
    fetchRequest.sortDescriptors = sortDescriptors
    var results = [NSManagedObject]()
    var error: NSError?
    results = context.executeFetchRequest(fetchRequest, error: &error)! as [NSManagedObject]
    return results
  }
}