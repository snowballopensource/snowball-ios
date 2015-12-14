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

  override func assignAttributes(attributes: ActiveModelAttributes) {
    if let id = attributes["id"] as? String {
      self.id = id
    }
    if let videoURL = attributes["video_url"] as? String {
      self.videoURL = videoURL
    }
    if let thumbnailURL = attributes["thumbnail_url"] as? String {
      self.thumbnailURL = thumbnailURL
    }
    if let liked = attributes["liked"] as? Bool {
      self.liked = liked
    }
    if let createdAt = attributes["created_at"] as? NSTimeInterval {
      self.createdAt = NSDate(timeIntervalSince1970: createdAt)
    }
    if let userAttributes = attributes["user"] as? JSONObject, let userID = userAttributes["id"] as? String {
      if let user = User.findOrNew(userID) as? User {
        user.assignAttributes(userAttributes)
        self.user = user
      }
    }
  }
}