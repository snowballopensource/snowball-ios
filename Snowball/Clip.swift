//
//  Clip.swift
//  Snowball
//
//  Created by James Martinez on 2/9/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Foundation

class Clip {
  var id: String?
  var videoURL: NSURL?
  var thumbnailURL: NSURL?
  var createdAt: NSDate?
  var user: User?

  // MARK: - Initializers

  init() {}

  // MARK: - Internal

  class func importJSON(JSON: [AnyObject]) -> [Clip] {
    var clips = [Clip]()
    for object in JSON {
      let clip = Clip()
      clip.assignAttributes(object)
      clips.append(clip)
    }
    return clips
  }

  func assignAttributes(attributes: AnyObject) {
    if let id = attributes["id"] as? String {
      self.id = id
    }
    if let videoURL = attributes["video_url"] as? String {
      self.videoURL = NSURL(string: videoURL)
    }
    if let thumbnailURL = attributes["thumbnail_url"] as? String {
      self.thumbnailURL = NSURL(string: thumbnailURL)
    }
    if let createdAt = attributes["created_at"] as? NSTimeInterval {
      self.createdAt = NSDate(timeIntervalSince1970: createdAt)
    }
    if let user: AnyObject = attributes["user"] {
      self.user = User.objectFromJSON(user) as? User
    }
  }

}