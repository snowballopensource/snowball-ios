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

// MARK: - ResponseObjectSerializable
extension Clip: ResponseObjectSerializable {
  init?(representation: AnyObject) {
    let json = JSON(representation)
    if
      let id = json["id"].string,
      let imageURL = json["image"]["standard_resolution"]["url"].URL,
      let videoURL = json["video"]["standard_resolution"]["url"].URL,
      let userRepresentation = json["user"].dictionaryObject,
      let user = User(representation: userRepresentation) {

      self.id = id
      self.imageURL = imageURL
      self.videoURL = videoURL
      self.user = user

      if let createdAtString = json["created_at"].string {
        self.createdAt = NSDate.dateFromISO8610String(createdAtString)
      }
    } else {
      return nil
    }
  }
}

// MARK: - ResponseCollectionSerializable
extension Clip: ResponseCollectionSerializable {}

// MARK: - CacheableModel
extension Clip: CacheableModel {

  var modelIdentifier: String? {
    return "Clip:\(id)"
  }

  init?(data: [NSObject : AnyObject]) {
    if
      let id = data["id"] as? String,
      let imageURLData = data["imageURL"] as? NSData,
      let imageURL = NSKeyedUnarchiver.unarchiveObjectWithData(imageURLData) as? NSURL,
      let videoURLData = data["videoURL"] as? NSData,
      let videoURL = NSKeyedUnarchiver.unarchiveObjectWithData(videoURLData) as? NSURL,
      let userData = data["user"] as? [NSObject: AnyObject],
      let user = User(data: userData)
    {

      self.id = id
      self.imageURL = imageURL
      self.videoURL = videoURL
      self.user = user

      if let createdAtData = data["createdAt"] as? NSData, let createdAt = NSKeyedUnarchiver.unarchiveObjectWithData(createdAtData) as? NSDate {
        self.createdAt = createdAt
      }
    } else {
      return nil
    }
  }

  func data() -> [NSObject : AnyObject] {
    var data = [
      "id": id,
      "imageURL": NSKeyedArchiver.archivedDataWithRootObject(imageURL),
      "videoURL": NSKeyedArchiver.archivedDataWithRootObject(videoURL),
      "user": user.data()
    ]
    if let createdAt = createdAt {
      data["createdAt"] = NSKeyedArchiver.archivedDataWithRootObject(createdAt)
    }
    return data
  }

  func map(transform: Model -> Model?) -> Clip? {
    guard let newUser = transform(user) as? User else { return nil }
    return Clip(id: id, imageURL: imageURL, videoURL: videoURL, createdAt: createdAt, user: newUser)
  }

  func forEach(visit: Model -> Void) {
    visit(user)
  }
}