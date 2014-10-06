//
//  Reel.swift
//  Snowball
//
//  Created by James Martinez on 9/22/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Foundation

class Reel: RemoteManagedObject, JSONPersistable {
  dynamic var title = ""
  dynamic var participantsTitle = ""
  dynamic var lastWatchedClip: Clip?

  func clips() -> RLMArray {
    return Clip.objectsInRealm(realm, withPredicate: NSPredicate(format: "reel == %@", self))
  }

  func recentClip() -> Clip? {
    return clips().arraySortedByProperty("createdAt", ascending: false).firstObject() as Clip?
  }

  func playableClips() -> RLMArray {
    if let clip = lastWatchedClip {
      return clips().objectsWithPredicate(NSPredicate(format: "createdAt >= %@", clip.createdAt))
    }
    return clips()
  }

  // MARK: JSONPersistable

  class func possibleJSONKeys() -> [String] {
    return ["reel", "reels"]
  }

  class func objectFromJSONObject(JSON: JSONObject) -> Self? {
    if let id = JSON["id"] as JSONData? as? String {
      var reel = findOrInitializeByID(id)

      if let title = JSON["title"] as JSONData? as? String {
        reel.title = title
      }
      if let participantsTitle = JSON["participants_title"] as JSONData? as? String {
        reel.participantsTitle = participantsTitle
      }
      if let recentClipJSON = JSON["recent_clip"] as JSONData? as JSONObject? {
        Clip.objectFromJSONObject(recentClipJSON)
      }

      return reel
    }
    return nil
  }
}