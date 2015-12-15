//
//  ActiveModel.swift
//  Snowball
//
//  Created by James Martinez on 12/10/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import Foundation
import RealmSwift

class ActiveModel: Object {

  // MARK: Properties

  private dynamic var _id = NSUUID().UUIDString

  // MARK: Typealias

  typealias Transaction = (object: ActiveModel) -> Void

  // MARK: Object

  final override class func primaryKey() -> String? {
    return "_id"
  }

  // MARK: Internal

  class func find(id: String) -> ActiveModel? {
    return findAll().filter("id = %@", id).first
  }

  class func findAll() -> Results<ActiveModel> {
    return Database.findAll(self)
  }

  class func findOrInitialize(id: String) -> ActiveModel {
    return find(id) ?? self.init()
  }

  func save() {
    Database.save(self)
  }

  func delete() {
    Database.delete(self)
  }
}

// MARK: - JSON

typealias JSONObject = [String: AnyObject]
typealias JSONArray = [JSONObject]

extension ActiveModel {

  func importJSON(JSON: JSONObject) {}

  static func fromJSONObject<T: ActiveModel>(JSON: JSONObject) -> T {
    if let id = JSON["id"] as? String {
      let object = findOrInitialize(id)
      object.importJSON(JSON)
      return object as! T
    }
    return T()
  }

  static func fromJSONArray<T: ActiveModel>(JSON: JSONArray) -> [T] {
    return JSON.map { JSON in
      return fromJSONObject(JSON)
    }
  }
}