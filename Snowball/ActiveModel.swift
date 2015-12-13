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

  class func create(transaction: Transaction) {
    self.init().update(transaction)
  }

  class func find(id: String) -> ActiveModel? {
    return findAll("id = %@", id).first
  }

  class func findAll(predicateFormat: String? = nil, _ args: AnyObject...) -> [ActiveModel] {
    var results = ActiveModel.realm.objects(self)
    if let predicateFormat = predicateFormat {
      results = results.filter(predicateFormat, args)
    }
    return Array<ActiveModel>(results)
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