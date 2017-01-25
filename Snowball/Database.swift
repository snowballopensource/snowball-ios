//
//  Database.swift
//  Snowball
//
//  Created by James Martinez on 12/14/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftFetchedResultsController

struct Database {

  // MARK: Properties

  static var realm: Realm {
    return try! Realm()
  }

  // MARK: Internal

  static func performTransaction(transaction: () -> Void) {
    try! realm.write(transaction)
  }

  static func save(object: Object) {
    realm.add(object, update: true)
  }

  static func delete(object: Object) {
    realm.delete(object)
  }

  static func findAll<T: Object>(type: T.Type) -> Results<T> {
    return realm.objects(type)
  }

  static func find<T: Object>(id: String) -> T? {
    return findAll(T).filter("id = %@", id).first
  }

  static func findOrInitialize<T: Object>(id: String) -> T {
    return find(id) ?? T()
  }
}
