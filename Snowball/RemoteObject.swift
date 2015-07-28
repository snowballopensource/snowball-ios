//
//  RemoteObject.swift
//  Snowball
//
//  Created by James Martinez on 12/9/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import CoreData

class RemoteObject: NSManagedObject {

  // MARK: - Internal

  class func objectFromJSON(JSON: AnyObject, context: NSManagedObjectContext = CoreDataStack.defaultStack.mainQueueManagedObjectContext) -> RemoteObject? {
    if let id = JSON["id"] as? String {
      let object = find(id, context: context) ?? newObject(context: context)
      if let object = object {
        object.assignAttributes(JSON as! [String: AnyObject])
      }
      return object as? RemoteObject
    }
    return nil
  }

  class func objectsFromJSON(JSON: AnyObject, context: NSManagedObjectContext = CoreDataStack.defaultStack.mainQueueManagedObjectContext) -> [RemoteObject] {
    var objects = [RemoteObject]()
    if let JSONArray = JSON as? [AnyObject] {
      for JSONObject in JSONArray {
        if let object = objectFromJSON(JSONObject, context: context) {
          objects.append(object)
        }
      }
    }
    return objects
  }
}