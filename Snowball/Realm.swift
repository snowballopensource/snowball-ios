//
//  Realm.swift
//  Snowball
//
//  Created by James Martinez on 9/17/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Foundation

class Realm: RLMRealm {
  class func saveInBackground(saveClosure: (realm: RLMRealm) -> (), completionClosure: () -> ()) {
    Async.userInitiated {
      let realm = RLMRealm.defaultRealm()
      realm.beginWriteTransaction()
      saveClosure(realm: realm)
      realm.commitWriteTransaction()
    }.main {
      completionClosure()
    }
  }
}