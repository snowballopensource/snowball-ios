//
//  User.swift
//  Snowball
//
//  Created by James Martinez on 8/9/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Foundation
import RocketData
import SwiftyJSON

struct User {
  let id: String
  var username: String
  var avatarURL: NSURL? = nil
  var color = UIColor.SnowballColor.randomColor()
}

// MARK: - Equatable
extension User: Equatable {}
func ==(lhs: User, rhs: User) -> Bool {
  return lhs.id == rhs.id
}

// MARK: - Hashable
extension User: Hashable {
  var hashValue: Int {
    return id.hashValue
  }
}

// MARK: - ResponseObjectSerializable
extension User: ResponseObjectSerializable {
  init?(representation: AnyObject) {
    let json = JSON(representation)
    if
      let id = json["id"].string,
      let username = json["username"].string {

      self.id = id
      self.username = username

      if let avatarURL = json["avatar_url"].URL {
        self.avatarURL = avatarURL
      }
    } else {
      return nil
    }
  }
}

// MARK: - ResponseCollectionSerializable
extension User: ResponseCollectionSerializable {}

// MARK: - CacheableModel
extension User: CacheableModel {

  var modelIdentifier: String? {
    return "User:\(id)"
  }

  init?(data: [NSObject : AnyObject]) {
    if
      let id = data["id"] as? String,
      let username = data["username"] as? String,
      let colorData = data["color"] as? NSData,
      let color = NSKeyedUnarchiver.unarchiveObjectWithData(colorData) as? UIColor {

      self.id = id
      self.username = username
      self.color = color

      if let avatarURLData = data["avatarURL"] as? NSData, let avatarURL = NSKeyedUnarchiver.unarchiveObjectWithData(avatarURLData) as? NSURL {
        self.avatarURL = avatarURL
      }
    } else {
      return nil
    }
  }

  func data() -> [NSObject : AnyObject] {
    var data = [
      "id": id,
      "username": username,
      "color": NSKeyedArchiver.archivedDataWithRootObject(color)
    ]
    if let avatarURL = avatarURL {
      data["avatarURL"] = NSKeyedArchiver.archivedDataWithRootObject(avatarURL)
    }
    return data
  }

  func map(transform: Model -> Model?) -> User? {
    // If I add nested models, transform them here using transform(modelName)
    // e.g. let newChild = transform(child) as? ChildModel
    return User(id: id, username: username, avatarURL: avatarURL, color: color)
  }

  func forEach(visit: Model -> Void) {
    // If I add nested models, visit them here using visit(modelName)
  }
}