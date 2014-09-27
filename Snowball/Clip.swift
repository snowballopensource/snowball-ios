//
//  Clip.swift
//  Snowball
//
//  Created by James Martinez on 9/22/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Foundation

class Clip: RLMObject {
  dynamic var id = ""
  dynamic var videoURL = ""
  dynamic var createdAt = NSDate(timeIntervalSince1970: 0)

  dynamic var user: User?
  dynamic var reel: Reel?

  // MARK: RLMObject

  override func updateFromDictionary(dictionary: [String: AnyObject]) {
    if let id = dictionary["id"] as AnyObject? as? String {
      self.id = id
    }
    if let videoURL = dictionary["video_url"] as AnyObject? as? String {
      self.videoURL = videoURL
    }
    if let createdAt = dictionary["created_at"] as AnyObject? as? Double  {
      self.createdAt = NSDate(timeIntervalSince1970: createdAt)
    }
    if let reelID = dictionary["reel_id"] as AnyObject? as? String {
      self.reel = Reel.importFromDictionary(["id": reelID], inRealm: self.realm) as Reel?
    }
  }
}