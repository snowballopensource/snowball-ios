//
//  Clip.swift
//  Snowball
//
//  Created by James Martinez on 8/8/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Foundation
import RocketData
import SwiftyJSON

struct Clip {
  let id: String
  let imageURL: NSURL
  let videoURL: NSURL
  var liked: Bool = false
  var createdAt: NSDate?
  let user: User
}

// MARK: - Equatable
extension Clip: Equatable {}
func ==(lhs: Clip, rhs: Clip) -> Bool {
  return lhs.id == rhs.id &&
    lhs.imageURL == rhs.imageURL &&
    lhs.videoURL == rhs.videoURL &&
    lhs.liked == rhs.liked &&
    lhs.createdAt == rhs.createdAt &&
    lhs.user == rhs.user
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

    if let liked = json["liked"].bool {
      self.liked = liked
    }
    if let createdAtString = json["created_at"].string {
      self.createdAt = NSDate.dateFromISO8610String(createdAtString)
    }
  }

  func asJSON() -> JSONObject {
    var json = JSONObject()
    json["id"] = id
    json["image"] = ["standard_resolution": ["url": imageURL.absoluteString]]
    json["video"] = ["standard_resolution": ["url": imageURL.absoluteString]]
    json["liked"] = liked
    json["created_at"] = createdAt?.iso8610String
    json["user"] = user.asJSON()
    return json
  }
}

// MARK: - Model
extension Clip: Model {
  var modelIdentifier: String? { return id }

  func map(transform: Model -> Model?) -> Clip? {
    guard let user = transform(user) as? User else { return nil }
    return Clip(id: id, imageURL: imageURL, videoURL: videoURL, liked: liked, createdAt: createdAt, user: user)
  }

  func forEach(visit: Model -> Void) {
    visit(user)
  }
}