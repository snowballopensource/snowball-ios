//
//  JSONImportable.swift
//  Snowball
//
//  Created by James Martinez on 10/24/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import Foundation

typealias JSONObject = [String: AnyObject]
typealias JSONArray = [JSONObject]

protocol JSONImportable {
  static func fromJSONObject(JSON: JSONObject) -> Self
  static func fromJSONArray(JSON: JSONArray) -> [Self]
}

extension JSONImportable {
  static func fromJSONArray(JSON: JSONArray) -> [Self] {
    return JSON.map { object in
      return fromJSONObject(object)
    }
  }
}