//
//  Clip.swift
//  Snowball
//
//  Created by James Martinez on 9/22/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Foundation

class Clip: RLMObject, JSONImportable {
  dynamic var id = ""
  dynamic var videoURL = ""
  dynamic var createdAt = NSDate(timeIntervalSince1970: 0)

  dynamic var user: User?
  dynamic var reel: Reel?

  // MARK: JSONImportable

  class func possibleJSONKeys() -> [String] {
    return ["clip", "clips"]
  }

  class func importFromJSONObject(JSON: JSONObject) -> AnyObject {
    var clip: Clip? = nil
    if let id = JSON["id"] as JSONData? as? String {
      if let existingClip = Clip.findByID(id) as? Clip {
        clip = existingClip
      } else {
        clip = Clip()
        RLMRealm.defaultRealm().addObject(clip)
        clip!.id = id
      }
    }
    if let videoURL = JSON["video_url"] as JSONData? as? String {
      clip!.videoURL = videoURL
    }
    if let createdAt = JSON["created_at"] as JSONData? as? Double  {
      clip!.createdAt = NSDate(timeIntervalSince1970: createdAt)
    }
    if let reelID = JSON["reel_id"] as JSONData? as? String {
      clip!.reel = Reel.importFromJSONObject(["id": reelID]) as? Reel
    }
    return clip!
  }
}