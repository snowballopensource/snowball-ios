//
//  Clip.swift
//  Snowball
//
//  Created by James Martinez on 2/9/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Foundation

class Clip: RemoteObject {

  // MARK: - Properties

  @NSManaged var id: String?
  @NSManaged var videoURL: String?
  @NSManaged var thumbnailURL: String?
  @NSManaged var liked: NSNumber
  @NSManaged var createdAt: NSDate?
  var user: User? // TODO: Represent this relationship in Core Data
  var state = ClipState.Default

  // MARK: - Internal

  override func assignAttributes(attributes: [String : AnyObject]) {
    if let id = attributes["id"] as? String {
      self.id = id
    }
    if let videoURL = attributes["video_url"] as? String {
      self.videoURL = videoURL
    }
    if let thumbnailURL = attributes["thumbnail_url"] as? String {
      self.thumbnailURL = thumbnailURL
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