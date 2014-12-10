//
//  User.swift
//  Snowball
//
//  Created by James Martinez on 12/6/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import CoreData
import UIKit

class User: RemoteObject {
  @NSManaged var id: String
  @NSManaged var name: String
  @NSManaged var username: String
  @NSManaged var avatarURL: String
  @NSManaged var following: NSNumber
  @NSManaged var clips: NSSet
  @NSManaged var color: AnyObject

  // MARK: - NSManagedObject

  override func awakeFromInsert() {
    super.awakeFromInsert()
    color = UIColor.SnowballColor.randomColor()
  }

  override func assign(attributes: AnyObject) {
    if let id = attributes["id"] as? String {
      self.id = id
    }
    if let name = attributes["name"] as? String {
      self.name = name
    }
    if let username = attributes["username"] as? String {
      self.username = username
    }
    if let avatarURL = attributes["avatar_url"] as? String {
      self.avatarURL = avatarURL
    }
    if let following = attributes["following"] as? Bool {
      self.following = following
    }
  }
}