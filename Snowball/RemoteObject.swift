//
//  RemoteObject.swift
//  Snowball
//
//  Created by James Martinez on 12/9/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import CoreData

class RemoteObject: NSManagedObject, JSONPersistable {

  // MARK: - JSONPersistable

  class func objectFromJSON(JSON: AnyObject) -> Self? {
    if let id = JSON["id"] as? String {
      let object = findOrInitialize(id)
      object.assign(JSON)
    }
    return nil
  }
}