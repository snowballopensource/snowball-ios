//
//  Clip.swift
//  Snowball
//
//  Created by James Martinez on 2/9/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Foundation

class Clip {

  // MARK: - Properties

  var id: String?
  var videoURL: NSURL?
  var thumbnailURL: NSURL?
  var liked = false
  var createdAt: NSDate?
  var user: User?
  var state = ClipState.Default

  // MARK: - Initializers

  init() {}

  // MARK: - Internal

  class func importJSON(JSON: [AnyObject]) -> [Clip] {
    var clips = [Clip]()
    for object in JSON {
      let clip = Clip()
      clip.assignAttributes(object)
      clips.append(clip)
    }
    return clips
  }

  func assignAttributes(attributes: AnyObject) {
    if let id = attributes["id"] as? String {
      self.id = id
    }
    if let videoURL = attributes["video_url"] as? String {
      self.videoURL = NSURL(string: videoURL)
    }
    if let thumbnailURL = attributes["thumbnail_url"] as? String {
      self.thumbnailURL = NSURL(string: thumbnailURL)
    }
    if let liked = attributes["liked"] as? Bool {
      self.liked = liked
    }
    if let createdAt = attributes["created_at"] as? NSTimeInterval {
      self.createdAt = NSDate(timeIntervalSince1970: createdAt)
    }
    if let user: AnyObject = attributes["user"] {
      self.user = User.objectFromJSON(user) as? User
    }
  }
}

// MARK: - Equatable

extension Clip: Equatable {}

func ==(lhs: Clip, rhs: Clip) -> Bool {
  let clipIDsAreNotNil = lhs.id != nil && rhs.id != nil
  if clipIDsAreNotNil && lhs.id == rhs.id {
    return true
  }
  if let lhsCreatedAt = lhs.createdAt, rhsCreatedAt = rhs.createdAt {
    let clipsCreatedAtSame = lhsCreatedAt.compare(rhsCreatedAt) == NSComparisonResult.OrderedSame
    return clipsCreatedAtSame
  }
  return false
}

enum ClipState {
  case Default, PendingUpload, Uploading, UploadFailed
}