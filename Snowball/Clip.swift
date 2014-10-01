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

  // MARK: JSONObjectSerializable

  class func objectFromJSON(JSON: [String: AnyObject]) -> AnyObject {
    let objectJSON = JSONForPossibleKeys(["clip"], inJSON: JSON)
    var clip: Clip? = nil
    if let id = objectJSON["id"] as AnyObject? as? String {
      if let existingClip = Clip.findByID(id) as? Clip {
        clip = existingClip
      } else {
        clip = Clip()
        RLMRealm.defaultRealm().addObject(clip)
        clip!.id = id
      }
    }
    if let videoURL = objectJSON["video_url"] as AnyObject? as? String {
      clip!.videoURL = videoURL
    }
    if let createdAt = objectJSON["created_at"] as AnyObject? as? Double  {
      clip!.createdAt = NSDate(timeIntervalSince1970: createdAt)
    }
    if let reelID = objectJSON["reel_id"] as AnyObject? as? String {
      clip!.reel = Reel.objectFromJSON(["id": reelID]) as? Reel
    }
    return clip!
  }

  class func arrayFromJSON(JSON: [String: AnyObject]) -> [AnyObject] {
    var clips = [AnyObject]()
    if let clipsJSON = JSON["clips"] as AnyObject? as? [AnyObject] {
      for JSONObject in clipsJSON {
        if let clipJSON = JSONObject as AnyObject? as? [String: AnyObject] {
          clips.append(Clip.objectFromJSON(clipJSON))
        }
      }
    }
    return clips
  }
}