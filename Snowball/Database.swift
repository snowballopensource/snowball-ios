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

  private static var realm: Realm {
    return try! Realm()
  }

  // MARK: Internal

  static func performTransaction(transaction: () -> Void) {
    try! realm.write(transaction)
  }

  static func save(object: ActiveModel) {
    realm.add(object, update: true)
  }

  static func delete(object: ActiveModel) {
    realm.delete(object)
  }

  static func findAll<T: ActiveModel>(type: T.Type) -> Results<T> {
    return realm.objects(type)
  }
}