//
//  Clip.swift
//  Snowball
//
//  Created by James Martinez on 12/10/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import Foundation

class Clip: ActiveModel {

  // MARK: Properties

  dynamic var id: String?
  dynamic var videoURL: String?
  dynamic var thumbnailURL: String?
  dynamic var liked = false
  dynamic var createdAt: NSDate?
  dynamic var user: User?

  // MARK: ActiveModel

  override func importJSON(JSON: JSONObject) {
    if let id = JSON["id"] as? String {
      self.id = id
    }
    if let videoURL = JSON["video_url"] as? String {
      self.videoURL = videoURL
    }
    if let thumbnailURL = JSON["thumbnail_url"] as? String {
      self.thumbnailURL = thumbnailURL
    }
    if let liked = JSON["liked"] as? Bool {
      self.liked = liked
    }
    if let createdAt = JSON["created_at"] as? NSTimeInterval {
      self.createdAt = NSDate(timeIntervalSince1970: createdAt)
    }
    if let userJSON = JSON["user"] as? JSONObject {
      self.user = User.fromJSONObject(userJSON) as User
    }
  }
}