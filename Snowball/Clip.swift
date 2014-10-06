//
//  Clip.swift
//  Snowball
//
//  Created by James Martinez on 9/22/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Foundation

class Clip: RemoteManagedObject, JSONPersistable {
  dynamic var videoURL = ""
  dynamic var createdAt = NSDate(timeIntervalSince1970: 0)

  dynamic var user: User?
  dynamic var reel: Reel?

  // MARK: JSONPersistable

  class func possibleJSONKeys() -> [String] {
    return ["clip", "clips"]
  }

  class func objectFromJSONObject(JSON: JSONObject) -> Self? {
    if let id = JSON["id"] as JSONData? as? String {
      var clip = findOrInitializeByID(id)

      if let videoURL = JSON["video_url"] as JSONData? as? String {
        clip.videoURL = videoURL
      }
      if let createdAt = JSON["created_at"] as JSONData? as? Double  {
        clip.createdAt = NSDate(timeIntervalSince1970: createdAt)
      }
      if let reelID = JSON["reel_id"] as JSONData? as? String {
        clip.reel = Reel.objectFromJSONObject(["id": reelID])
      }

      return clip
    }
    return nil
  }
}