//
//  Realm.swift
//  Snowball
//
//  Created by James Martinez on 9/17/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Foundation

class Realm: RLMRealm {
  class func saveInBackground(closure: (realm: RLMRealm) -> ()) {
    let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    dispatch_async(queue) {
      let realm = RLMRealm.defaultRealm()
      realm.beginWriteTransaction()
      closure(realm: realm)
      realm.commitWriteTransaction()
    }
  }
}