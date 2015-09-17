//
//  CoreDataStack.swift
//  CoreRecord
//
//  Created by James Martinez on 2/13/15.
//  Copyright (c) 2015 James Martinez. All rights reserved.
//

import CoreData
import Foundation

public class CoreDataStack {

  // MARK: - Singleton

  private struct Singleton {
    static var defaultStack: CoreDataStack!
  }

  // MARK: - Properties

  public class var defaultStack: CoreDataStack {
    set {
    Singleton.defaultStack = newValue
    }
    get {
      if Singleton.defaultStack == nil {
        Singleton.defaultStack = CoreDataStack()
      }
      return Singleton.defaultStack
    }
  }

  public let mainQueueManagedObjectContext: NSManagedObjectContext
  public let privateQueueManagedObjectContext: NSManagedObjectContext

  // MARK: - Initializers

  public convenience init() {
    let stackName = NSBundle.mainBundle().infoDictionary!["CFBundleName"] as! String

    let modelURL = NSBundle.mainBundle().URLForResource(stackName, withExtension: "momd")!
    let managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL)!

    let documentDirectory = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as! NSURL
    let databaseURL = documentDirectory.URLByAppendingPathComponent("\(stackName).sqlite")

    self.init(databaseURL: databaseURL, model: managedObjectModel)
  }

  public init(databaseURL: NSURL, model: NSManagedObjectModel) {
    let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
    var error: NSError?
    do {
      try persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: databaseURL, options: nil)
    } catch let error1 as NSError {
      error = error1
    }
    if error != nil {
      print("Failed to initialize the application's saved data. There was an error creating or loading the application's saved data. Error: \(error)")
      do {
        try NSFileManager.defaultManager().removeItemAtURL(databaseURL)
      } catch _ {
      }
      print("The existing store has been deleted and a new store will be created on the next launch.")
      abort()
    }

    mainQueueManagedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
    mainQueueManagedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator

    privateQueueManagedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
    privateQueueManagedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator

    NSNotificationCenter.defaultCenter().addObserver(self, selector: "managedObjectContextDidSaveNotification:", name: NSManagedObjectContextDidSaveNotification, object: mainQueueManagedObjectContext)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "managedObjectContextDidSaveNotification:", name: NSManagedObjectContextDidSaveNotification, object: privateQueueManagedObjectContext)
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  // MARK: - Private

  @objc private func managedObjectContextDidSaveNotification(notification: NSNotification) {
    if let context = notification.object as? NSManagedObjectContext {
      context.performBlock {
        context.mergeChangesFromContextDidSaveNotification(notification)
      }
    }
  }
}