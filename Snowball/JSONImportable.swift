//
//  JSONImportable.swift
//  Snowball
//
//  Created by James Martinez on 10/21/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import Foundation

typealias JSONObject = [String: AnyObject]
typealias JSONArray = [JSONObject]

protocol JSONImportable {
  init?(JSON: JSONObject)
  static func objectsFromJSONArray(JSON: JSONArray) -> [Self]
}

extension JSONImportable {
  static func objectsFromJSONArray(JSON: JSONArray) -> [Self] {
    var objects = [Self]()
    for JSONObject in JSON {
      if let object = Self(JSON: JSONObject) {
        objects.append(object)
      }
    }
    return objects
  }
}



//  class func objectFromJSON(JSON: JSONObject, context: NSManagedObjectContext = CoreDataStack.defaultStack.mainQueueManagedObjectContext) -> Self? {
//    if let id = JSON["id"] as? String {
//      let object = find(id, context: context) ?? newObject(context: context)
//      if let object = object {
//        object.assignAttributes(JSON)
//      }
//      return object as? Self.Type
//    }
//    return nil
//  }
//
//  class func objectsFromJSON(JSON: JSONArray, context: NSManagedObjectContext = CoreDataStack.defaultStack.mainQueueManagedObjectContext) -> [Self] {
//    var objects = [Self]()
//    for JSONObject in JSON {
//      if let object = objectFromJSON(JSONObject, context: context) {
//        objects.append(object)
//      }
//    }
//    return objects
//  }