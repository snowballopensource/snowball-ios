//
//  RLMObject.swift
//  Snowball
//
//  Created by James Martinez on 9/18/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Foundation

extension RLMObject {
  class func findByID(id: String) -> AnyObject? {
    let objects = objectsWithPredicate(NSPredicate(format: "id == %@", id))
    return objects.firstObject()
  }

  class func createFromDictionary(dictionary: [String: AnyObject], inRealm realm: RLMRealm) -> AnyObject? {
    let object = self()
    object.updateFromDictionary(dictionary)
    realm.addObject(object)
    return object
  }

  func updateFromDictionary(dictionary: [String: AnyObject]) {}

  class func createOrUpdateFromDictionary(dictionary: [String: AnyObject], inRealm realm: RLMRealm) -> AnyObject? {
    let id = dictionary["id"] as AnyObject? as? String
    var object: AnyObject? = findByID(id!)
    if (object != nil) {
      object?.updateFromDictionary(dictionary)
      return object
    }
    object = createFromDictionary(dictionary, inRealm: realm)
    return object
  }
}