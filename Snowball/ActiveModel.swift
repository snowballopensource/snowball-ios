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

  private class var realm: Realm {
    return try! Realm()
  }

  // MARK: Typealias

  typealias Transaction = (object: ActiveModel) -> Void

  // MARK: Object

  final override class func primaryKey() -> String? {
    return "_id"
  }

  // MARK: Internal

  class func create(transaction: Transaction) -> ActiveModel {
    let object = self.init()
    object.update(transaction)
    return object
  }

  class func find(id: String) -> ActiveModel? {
    return findAll("id = %@", id).first
  }

  class func findAll(predicateFormat: String? = nil, _ args: AnyObject...) -> Results<ActiveModel> {
    var results = ActiveModel.realm.objects(self)
    if let predicateFormat = predicateFormat {
      results = results.filter(NSPredicate(format: predicateFormat, argumentArray: args))
    }
    return results
  }

  class func findOrNew(id: String) -> ActiveModel {
    return find(id) ?? self.init()
  }

  func update(transaction: Transaction) {
    try! ActiveModel.realm.write {
      transaction(object: self)
      ActiveModel.realm.add(self, update: true)
    }
  }

  func delete() {
    try! ActiveModel.realm.write {
      ActiveModel.realm.delete(self)
    }
  }
}

// MARK: - JSON

typealias ActiveModelAttributes = [String: AnyObject]
typealias JSONObject = [String: AnyObject]
typealias JSONArray = [JSONObject]

extension ActiveModel {

  func assignAttributes(attributes: ActiveModelAttributes) {}

  static func fromJSONObject<T>(JSON: JSONObject) -> T {
    if let id = JSON["id"] as? String {
      let object = findOrNew(id)
      object.update { object in
        object.assignAttributes(JSON)
      }
      return object as! T
    }
    return create({ _ in }) as! T
  }

  static func fromJSONArray<T>(JSON: JSONArray) -> [T] {
    return JSON.map { JSON in
      return fromJSONObject(JSON)
    }
  }
}