// Copyright: 2017, Bryan Summersett. All rights reserved.

import Foundation
import RealmSwift

extension Realm {
  static func removeAllFiles() {
    let fileManager = FileManager.default
    let config = Realm.Configuration.defaultConfiguration
    let fileURL = config.fileURL!
    let fileURLs = [
      fileURL,
      fileURL.appendingPathExtension("lock"),
      fileURL.appendingPathExtension("log_a"),
      fileURL.appendingPathExtension("log_b"),
      fileURL.appendingPathExtension("note")
    ]
    for url in fileURLs {
      do {
        try fileManager.removeItem(at: url)
      } catch let error {
        print(error.localizedDescription)
      }
    }
  }

  static func deleteRealmIfMigrationNeeded() {
    var config = Realm.Configuration()
    config.deleteRealmIfMigrationNeeded = true
    Realm.Configuration.defaultConfiguration = config
  }
}
