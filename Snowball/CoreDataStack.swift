//
//  CoreDataStack.swift
//  Snowball
//
//  Created by James Martinez on 12/6/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import CoreData

// This class is just Apple's sample code moved to a separate file
// with a little bit of cleanup. Cool, huh?

class CoreDataStack {
  let stackName = coreRecordAppName

  class var defaultStack: CoreDataStack {
    // https://github.com/hpique/SwiftSingleton#approach-b-nested-struct
    struct Singleton {
      static let defaultStack: CoreDataStack = CoreDataStack()
    }
    return Singleton.defaultStack
  }

  private lazy var applicationDocumentsDirectory: NSURL = {
    let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    return urls[urls.count-1] as NSURL
    }()

  private lazy var managedObjectModel: NSManagedObjectModel = {
    let modelURL = NSBundle.mainBundle().URLForResource(self.stackName, withExtension: "momd")!
    return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

  private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
    var coordinator: NSPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("\(self.stackName).sqlite")
    var error: NSError? = nil
    if coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
      let dict = NSMutableDictionary()
      dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
      dict[NSLocalizedFailureReasonErrorKey] = "There was an error creating or loading the application's saved data."
      dict[NSUnderlyingErrorKey] = error
      error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
      NSLog("Unresolved error \(error), \(error!.userInfo)")
      abort()
    }
    return coordinator
    }()

  lazy var mainQueueManagedObjectContext: NSManagedObjectContext = {
    return CoreDataStack.newManagedObjectContextWithCoordinator(self.persistentStoreCoordinator, concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
  }()

  lazy var privateQueueManagedObjectContext: NSManagedObjectContext = {
    return CoreDataStack.newManagedObjectContextWithCoordinator(self.persistentStoreCoordinator, concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
    }()

  // MARK: - Initializers

  init() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "contextDidSaveMainQueueManagedObjectContext:", name: NSManagedObjectContextDidSaveNotification, object: self.mainQueueManagedObjectContext)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "contextDidSavePrivateQueueManagedObjectContext:", name: NSManagedObjectContextDidSaveNotification, object: self.privateQueueManagedObjectContext)
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  // MARK: - Notifications
  // Since this class is not an NSObject, we add @objc to allow this to work.
  // http://stackoverflow.com/a/24416671

  @objc private func contextDidSaveMainQueueManagedObjectContext(notification: NSNotification) {
    privateQueueManagedObjectContext.performBlock {
      self.privateQueueManagedObjectContext.mergeChangesFromContextDidSaveNotification(notification)
    }
  }

  @objc private func contextDidSavePrivateQueueManagedObjectContext(notification: NSNotification) {
    mainQueueManagedObjectContext.performBlock {
      self.mainQueueManagedObjectContext.mergeChangesFromContextDidSaveNotification(notification)
    }
  }

  // MARK: - Private

  private class func newManagedObjectContextWithCoordinator(persistentStoreCoordinator: NSPersistentStoreCoordinator, concurrencyType: NSManagedObjectContextConcurrencyType) -> NSManagedObjectContext {
    let managedObjectContext = NSManagedObjectContext(concurrencyType: concurrencyType)
    managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
    return managedObjectContext
  }
}