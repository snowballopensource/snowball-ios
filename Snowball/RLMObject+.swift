//
//  RLMObject+.swift
//  Snowball
//
//  Created by James Martinez on 9/18/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Foundation

extension RLMObject {
  class func findByID(id: String, inRealm realm: RLMRealm) -> AnyObject? {
    let objects = objectsInRealm(realm, withPredicate: NSPredicate(format: "id = %@", id))
    return objects.firstObject()
  }

  class func createFromDictionary(dictionary: [String: AnyObject], inRealm realm: RLMRealm) -> AnyObject? {
    let object = self()
    realm.addObject(object)
    object.updateFromDictionary(dictionary)
    return object
  }

  class func importFromDictionary(dictionary: [String: AnyObject], inRealm realm: RLMRealm) -> AnyObject? {
    if let id = dictionary["id"] as AnyObject? as? String {
      if var object: AnyObject = findByID(id, inRealm: realm) {
        object.updateFromDictionary(dictionary)
        return object
      } else {
        return createFromDictionary(dictionary, inRealm: realm)
      }
    }
    return nil
  }

  class func importFromArray(array: [AnyObject], inRealm realm: RLMRealm) {
    for object in array {
      if let dictionary = object as? [String: AnyObject] {
        importFromDictionary(dictionary, inRealm: realm)
      }
    }
  }

  func updateFromDictionary(dictionary: [String: AnyObject]) {}
}