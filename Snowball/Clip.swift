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

  class var playableClips: RLMResults {
    return Clip.allObjects().sortedResultsUsingProperty("createdAt", ascending: true)
  }

  class var kLastWatchedClipIDKey: String {
    return "LastWatchedClipID"
  }
  class var lastWatchedClip: Clip? {
    get {
      let lastWatchedClipID = NSUserDefaults.standardUserDefaults().objectForKey(kLastWatchedClipIDKey) as String?
      if let clipID = lastWatchedClipID {
        return Clip.findByID(clipID)
      }
      return nil
    }
    set {
      if let clip = newValue {
        NSUserDefaults.standardUserDefaults().setObject(clip.id, forKey: kLastWatchedClipIDKey)
      } else {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kLastWatchedClipIDKey)
      }
      NSUserDefaults.standardUserDefaults().synchronize()
    }
  }

  // MARK: JSONPersistable

  class func objectFromJSONObject(JSON: JSONObject) -> Self? {
    if let id = JSON["id"] as JSONData? as? String {
      var clip = findOrInitializeByID(id)

      if let videoURL = JSON["video_url"] as JSONData? as? String {
        clip.videoURL = videoURL
      }
      if let createdAt = JSON["created_at"] as JSONData? as? Double  {
        clip.createdAt = NSDate(timeIntervalSince1970: createdAt)
      }
      if let user = JSON["user"] as? JSONObject {
        clip.user = User.objectFromJSONObject(user)!
      }

      return clip
    }
    return nil
  }
}