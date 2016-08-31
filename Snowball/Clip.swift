//
//  Clip.swift
//  Snowball
//
//  Created by James Martinez on 8/8/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Clip {
  let id: String
  let imageURL: NSURL
  let videoURL: NSURL
  var createdAt: NSDate?
  let user: User
}

// MARK: - Equatable
extension Clip: Equatable {}
func ==(lhs: Clip, rhs: Clip) -> Bool {
  return lhs.id == rhs.id
}

// MARK: - Hashable
extension Clip: Hashable {
  var hashValue: Int {
    return id.hashValue
  }
}

// MARK: - JSONRepresentable
extension Clip: JSONRepresentable {
  init?(json: JSONObject) {
    let json = JSON(json)
    guard
      let id = json["id"].string,
      let imageURL = json["image"]["standard_resolution"]["url"].URL,
      let videoURL = json["video"]["standard_resolution"]["url"].URL,
      let userJSON = json["user"].dictionaryObject,
      let user = User(json: userJSON)
      else {
        return nil
    }

    self.id = id
    self.imageURL = imageURL
    self.videoURL = videoURL
    self.user = user

    if let createdAtString = json["created_at"].string {
      self.createdAt = NSDate.dateFromISO8610String(createdAtString)
    }
  }

  func asJSON() -> JSONObject {
    var json = JSONObject()
    json["id"] = id
    json["image"] = ["standard_resolution": ["url": imageURL.absoluteString]]
    json["video"] = ["standard_resolution": ["url": imageURL.absoluteString]]
    json["created_at"] = createdAt?.iso8610String
    json["user"] = user.asJSON()
    return json
  }
}