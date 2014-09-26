//
//  Realm.swift
//  Snowball
//
//  Created by James Martinez on 9/17/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Foundation

class Realm: RLMRealm {
  typealias SaveHandler = (realm: RLMRealm) -> ()
  typealias CompletionHandler = () -> ()

  class func saveInBackground(saveHandler: SaveHandler, completionHandler: CompletionHandler?) {
    Async.userInitiated {
      let realm = RLMRealm.defaultRealm()
      realm.beginWriteTransaction()
      saveHandler(realm: realm)
      realm.commitWriteTransaction()
    }.main {
      if let completion = completionHandler { completion() }
    }
  }

  class func save(saveHandler: SaveHandler) {
    saveInBackground(saveHandler, completionHandler: nil)
  }

}