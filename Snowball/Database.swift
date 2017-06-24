//
//  Database.swift
//  Snowball
//
//  Created by James Martinez on 12/14/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import Foundation
import RealmSwift

struct Database {

  // MARK: Properties

  static var realm: Realm {
    return try! Realm()
  }

  // MARK: Internal

  static func performTransaction(_ transaction: () -> Void) {
    try! realm.write(transaction)
  }

  static func save(_ object: Object) {
    realm.add(object, update: true)
  }

  static func delete(_ object: Object) {
    realm.delete(object)
  }

  static func findAll<T: Object>(_ type: T.Type) -> Results<T> {
    return realm.objects(type)
  }

  static func find<T: Object>(_ id: String) -> T? {
    return findAll(T.self).filter("id = %@", id).first
  }

  static func findOrInitialize<T: Object>(_ id: String) -> T {
    return find(id) ?? T()
  }
}
