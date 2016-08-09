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
  init?(response: NSHTTPURLResponse, representation: AnyObject) {
    let json = JSON(representation)
    if
      let id = json["id"].string,
      let imageURL = json["image"]["standard_resolution"]["url"].URL,
      let videoURL = json["video"]["standard_resolution"]["url"].URL,
      let userRepresentation = json["user"].dictionaryObject,
      let user = User(response: response, representation: userRepresentation) {

      self.id = id
      self.imageURL = imageURL
      self.videoURL = videoURL
      self.user = user
    } else {
      return nil
    }
  }
}

// MARK: - ResponseCollectionSerializable
extension Clip: ResponseCollectionSerializable {}