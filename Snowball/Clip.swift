//
//  Clip.swift
//  Snowball
//
//  Created by James Martinez on 12/6/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import CoreData

class Clip: RemoteObject {
  @NSManaged var id: String?
  @NSManaged var videoURL: String
  @NSManaged var createdAt: NSDate
  @NSManaged var user: User

  // MARK: - NSManagedObject

  override func assign(attributes: AnyObject) {
    if let id = attributes["id"] as? String {
      self.id = id
    }
    if let videoURL = attributes["video_url"] as? String {
      self.videoURL = videoURL
    }
    if let createdAt = attributes["created_at"] as? NSTimeInterval {
      self.createdAt = NSDate(timeIntervalSince1970: createdAt)
    }
    if let userJSON: AnyObject = attributes["user"] {
      if let user = User.objectFromJSON(userJSON, context: managedObjectContext!) {
        self.user = user as User
      }
    }
  }
}