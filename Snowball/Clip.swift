//
//  Clip.swift
//  Snowball
//
//  Created by James Martinez on 12/10/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import RealmSwift
import Foundation

class Clip: Object {

  // MARK: Properties

  dynamic var _id = UUID().uuidString
  dynamic var id: String?
  dynamic var videoURL: String?
  dynamic var thumbnailURL: String?
  dynamic var liked = false
  dynamic var createdAt: Date?
  dynamic var user: User?
  dynamic var inHomeTimeline = false
  dynamic var timelineID: String?
  private dynamic var stateString = ClipState.Default.rawValue

  var state: ClipState {
    get {
      return ClipState(rawValue: stateString) ?? .Default
    }
    set {
      stateString = newValue.rawValue
    }
  }

  // MARK: Object

  override static func primaryKey() -> String? {
    return "_id"
  }

  override static func ignoredProperties() -> [String] {
    return ["state"]
  }

  override func importJSON(_ JSON: JSONObject) {
    if let id = JSON["id"] as? String {
      if self.id == nil {
        self.id = id
      }
    }
    if let video = JSON["video"] as? JSONObject,
      let standardRes = video["standard_resolution"] as? JSONObject,
      let videoURL = standardRes["url"] as? String {
      self.videoURL = videoURL
    }
    if let image = JSON["image"] as? JSONObject,
      let standardRes = image["standard_resolution"] as? JSONObject,
      let imageURL = standardRes["url"] as? String {
      self.thumbnailURL = imageURL
    }
    if let liked = JSON["liked"] as? Bool {
      self.liked = liked
    }
    if let createdAt = JSON["created_at"] as? String {
      self.createdAt = Date.dateFromISO8610String(createdAt)
    }
    if let userJSON = JSON["user"] as? JSONObject {
      self.user = User.fromJSONObject(userJSON)
    }
  }

  // MARK: Internal

  static func cleanUpFailedClipUploads() {
    Database.performTransaction {
      for clip in Database.findAll(Clip.self).filter("stateString == %@", ClipState.Uploading.rawValue) {
        clip.state = ClipState.UploadFailed
        Database.save(clip)
      }
    }
  }
}

// MARK: - ClipState
enum ClipState: String {
  case Default = "Default"
  case PendingAcceptance = "PendingAcceptance"
  case Uploading = "Uploading"
  case UploadFailed = "UploadFailed"
}
