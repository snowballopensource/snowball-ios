//
//  Clip.swift
//  Snowball
//
//  Created by James Martinez on 2/9/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Foundation

final class Clip: RemoteObject {

  // MARK: - Properties

  @NSManaged var id: String?
  @NSManaged var videoURL: String?
  @NSManaged var thumbnailURL: String?
  @NSManaged var liked: NSNumber
  @NSManaged var createdAt: NSDate?
  @NSManaged var user: User?
  @NSManaged private var stateString: String?

  var state: ClipState {
    get {
      if let stateString = stateString {
        return ClipState(rawValue: stateString) ?? ClipState.Default
      }
      return ClipState.Default
    }
    set {
      stateString = newValue.rawValue
    }
  }

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

  class func cleanupUploadingStates() {
    let predicate = NSPredicate(format: "stateString == %@", ClipState.Uploading.rawValue)
    let clips = Clip.findAll(predicate: predicate) as! [Clip]
    for clip in clips {
      clip.state == ClipState.UploadFailed
    }
    do { try CoreDataStack.defaultStack.mainQueueManagedObjectContext.save() } catch {}
  }
}

// MARK: - Equatable

func ==(lhs: Clip, rhs: Clip) -> Bool {
  let aClipIdIsNil = lhs.id == nil || rhs.id == nil
  if !aClipIdIsNil && lhs.id == rhs.id {
    return true
  } else if aClipIdIsNil {
    if let lhsCreatedAt = lhs.createdAt, rhsCreatedAt = rhs.createdAt {
      let clipsCreatedAtSame = lhsCreatedAt.compare(rhsCreatedAt) == NSComparisonResult.OrderedSame
      return clipsCreatedAtSame
    }
  }
  return false
}

enum ClipState: String {
  case Default = "Default"
  case PendingUpload = "PendingUpload"
  case Uploading = "Uploading"
  case UploadFailed = "UploadFailed"
}

// MARK: - JSONImportable
extension Clip: JSONImportable {
  static func fromJSONObject(JSON: JSONObject) -> Clip {
    return findOrNewObject(JSON) as! Clip
  }
}