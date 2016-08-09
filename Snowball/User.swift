//
//  User.swift
//  Snowball
//
//  Created by James Martinez on 8/9/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

struct User {
  let id: String
  var username: String
  var avatarURL: NSURL? = nil
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