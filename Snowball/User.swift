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
  let color = UIColor.SnowballColor.randomColor()
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

// MARK: - JSONRepresentable
extension User: JSONRepresentable {
  init?(json: JSONObject) {
    let json = JSON(json)
    guard
      let id = json["id"].string,
      let username = json["username"].string
      else {
        return nil
    }

    self.id = id
    self.username = username

    if let avatarURL = json["avatar_url"].URL {
      self.avatarURL = avatarURL
    }
  }
}