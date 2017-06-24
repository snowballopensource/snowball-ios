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

  let realm: Realm

  init() {
    realm = try! Realm()
  }

  // MARK: Internal

  func performTransaction(_ transaction: () -> Void) {
    try! realm.write(transaction)
  }

  func save(_ object: Object) {
    realm.add(object, update: true)
  }

  func delete(_ object: Object) {
    realm.delete(object)
  }

  func findAll<T>(_ type: T.Type) -> Results<T> {
    return realm.objects(type)
  }

  func find<T: Object>(_ id: String) -> T? {
    return findAll(T.self).filter("id = %@", id).first
  }

  func findOrInitialize<T: Object>(_ id: String) -> T {
    return find(id) ?? T()
  }
}
