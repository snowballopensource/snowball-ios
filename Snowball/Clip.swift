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
  let videoURL: NSURL
}

// MARK: - Equatable
extension Clip: Equatable {}
func ==(lhs: Clip, rhs: Clip) -> Bool {
  return lhs.id == rhs.id
}

// MARK: - ResponseObjectSerializable
extension Clip: ResponseObjectSerializable {
  init?(response: NSHTTPURLResponse, representation: AnyObject) {
    let json = JSON(representation)
    if
      let id = json["id"].string,
      let videoURLString = json["video"]["standard_resolution"]["url"].string,
      let videoURL = NSURL(string: videoURLString) {

      self.id = id
      self.videoURL = videoURL
    } else {
      return nil
    }
  }
}

// MARK: - ResponseCollectionSerializable
extension Clip: ResponseCollectionSerializable {}