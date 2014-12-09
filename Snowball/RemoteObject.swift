//
//  RemoteObject.swift
//  Snowball
//
//  Created by James Martinez on 12/9/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import CoreData

class RemoteObject: NSManagedObject {

  // MARK: - JSON Parsing

  class func importFromJSON(JSON: AnyObject, context: NSManagedObjectContext) {
    if JSON is [AnyObject] {
      objectsFromJSON(JSON, context: context)
    } else {
      objectFromJSON(JSON, context: context)
    }
  }

  class func objectFromJSON(JSON: AnyObject, context: NSManagedObjectContext) -> Self? {
    if let id = JSON["id"] as? String {
      let object = findOrInitialize(id, context: context)
      object.assign(JSON)
    }
    return nil
  }

  class func objectsFromJSON(JSON: AnyObject, context: NSManagedObjectContext) -> [RemoteObject] {
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