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

  static func fromJSONObject<T: Object>(JSON: JSONObject) -> T {
    if let id = JSON["id"] as? String {
      let object: T = Database.findOrInitialize(id)
      object.importJSON(JSON)
      return object
    }
    return T()
  }

  static func fromJSONArray<T: Object>(JSON: JSONArray) -> [T] {
    return JSON.map { JSON in
      return fromJSONObject(JSON)
    }
  }
}

// MARK: - JSON

typealias JSONObject = [String: AnyObject]
typealias JSONArray = [JSONObject]