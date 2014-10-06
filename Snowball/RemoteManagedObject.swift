//
//  RemoteManagedObject.swift
//  Snowball
//
//  Created by James Martinez on 10/5/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Foundation

class RemoteManagedObject: RLMObject {
  dynamic var id = ""

  required convenience init(id: String) {
    self.init()
    self.id = id
  }

  class func findByID(id: String) -> Self? {
    return self(forPrimaryKey: id as NSString)
  }

  class func findOrInitializeByID(id: String) -> Self {
    if let object = findByID(id) {
      return object
    }
    let object = self(id: id)
    RLMRealm.defaultRealm().addObject(object)
    return object
  }

  // MARK: RLMObject

  override class func primaryKey() -> String {
    return "id"
  }
}