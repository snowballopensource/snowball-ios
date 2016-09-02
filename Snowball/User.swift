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
  return lhs.id == rhs.id &&
    lhs.username == rhs.username &&
    lhs.avatarURL == rhs.avatarURL &&
    lhs.color == rhs.color
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
    if let colorHex = json["color"].string {
      self.color = UIColor(hex: colorHex)
    }
  }

  func asJSON() -> JSONObject {
    var json = JSONObject()
    json["id"] = id
    json["username"] = username
    json["avatar_url"] = avatarURL?.absoluteString
    json["color"] = color.hexValue
    return json
  }
}

// MARK: - Model
extension User: Model {
  var modelIdentifier: String? { return id }

  func map(transform: Model -> Model?) -> User? {
    return self
  }

  func forEach(visit: Model -> Void) {}
}