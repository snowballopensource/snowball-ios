//
//  NSManagedObjectExtension.swift
//  CoreRecord
//
//  Created by James Martinez on 2/13/15.
//  Copyright (c) 2015 James Martinez. All rights reserved.
//

import CoreData
import Foundation

extension NSManagedObject {

  // MARK: - Properties

  public class var entityName: String {
    return NSStringFromClass(self).componentsSeparatedByString(".").last!
  }

  public class var primaryKey: String {
    return "id"
  }

  // MARK: - Creation

  public class func newObject(attributes: [String: AnyObject]? = nil, context: NSManagedObjectContext = CoreDataStack.defaultStack.mainQueueManagedObjectContext) -> NSManagedObject? {
    let object = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: context) as? NSManagedObject
    if let attributes = attributes {
      object?.assignAttributes(attributes)
    }
    return object
  }

  // MARK: - Attribute Assignment

  public func assignAttributes(attributes: [String: AnyObject]) {
    for key in attributes.keys {
      setValue(attributes[key], forKey: key)
    }
  }

  // MARK: - Finders

  public class func count(context: NSManagedObjectContext = CoreDataStack.defaultStack.mainQueueManagedObjectContext) -> Int {
    let entityDescription = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context)
    let fetchRequest = NSFetchRequest(entityName: entityName)
    fetchRequest.entity = entityDescription
    return context.countForFetchRequest(fetchRequest, error: nil)
  }

  public class func find(primaryKey: String, context: NSManagedObjectContext = CoreDataStack.defaultStack.mainQueueManagedObjectContext) -> NSManagedObject? {
    let predicate = NSPredicate(format: "%K == %@", self.primaryKey, primaryKey)
    return findAll(predicate: predicate, context: context).first
  }

  public class func findAll(predicate: NSPredicate? = nil, limit: Int = 0, offset: Int = 0, sortDescriptors: [NSSortDescriptor]? = nil, context: NSManagedObjectContext = CoreDataStack.defaultStack.mainQueueManagedObjectContext) -> [NSManagedObject] {
    let entityDescription = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context)
    let fetchRequest = NSFetchRequest(entityName: entityName)
    fetchRequest.entity = entityDescription
    fetchRequest.predicate = predicate
    fetchRequest.fetchLimit = limit
    fetchRequest.fetchOffset = offset
    fetchRequest.sortDescriptors = sortDescriptors
    if let results = context.executeFetchRequest(fetchRequest, error: nil) as? [NSManagedObject] {
      return results
    }
    return [NSManagedObject]()
  }

  // MARK: - Deletion

  public func delete(context: NSManagedObjectContext = CoreDataStack.defaultStack.mainQueueManagedObjectContext) {
    context.deleteObject(self)
  }
}