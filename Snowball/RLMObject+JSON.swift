//
//  RLMObject+JSON.swift
//  Snowball
//
//  Created by James Martinez on 2/10/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Foundation
import RealmSwift

extension Object {

  // MARK: Internal

  func importJSON(JSON: JSONObject) {}

  static func fromJSONObject<T: Object>(JSON: JSONObject, beforeSave: ((object: T) -> Void)? = nil) -> T? {
    if let id = JSON["id"] as? String {
      let object: T = Database.findOrInitialize(id)
      object.importJSON(JSON)
      beforeSave?(object: object)
      Database.save(object)
      return object
    }
    return nil
  }

  static func fromJSONArray<T: Object>(JSON: JSONArray, beforeSaveEveryObject: ((object: T) -> Void)? = nil) -> [T] {
    var results = [T]()
    for JSONObject in JSON {
      let object: T? = T.fromJSONObject(JSONObject, beforeSave: beforeSaveEveryObject)
      if let object = object {
        results.append(object)
      }
    }
    return results
  }
}

// MARK: - JSON

typealias JSONObject = [String: AnyObject]
typealias JSONArray = [JSONObject]