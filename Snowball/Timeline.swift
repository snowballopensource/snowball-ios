//
//  Timeline.swift
//  Snowball
//
//  Created by James Martinez on 1/18/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Foundation
import RealmSwift

class Timeline {

  // MARK: Properties

  let type: TimelineType
  let clips: Results<ActiveModel>
  private let kClipBookmarkDateKey = "ClipBookmarkDate"
  var bookmarkedClip: Clip? {
    get {
      let filteredClips = clips.filter("id != NULL")
      if let bookmarkDate = NSUserDefaults.standardUserDefaults().objectForKey(kClipBookmarkDateKey) as? NSDate {
        if let clipAfterBookmark = filteredClips.filter("createdAt > %@", bookmarkDate).first as? Clip {
          return clipAfterBookmark
        }
        if let clipAtBookmark = filteredClips.filter("createdAt == %@", bookmarkDate).first as? Clip {
          return clipAtBookmark
        }
      }
      return filteredClips.first as? Clip
    }
    set {
      if let newClipBookmarkDate = newValue?.createdAt, let oldClipBookmarkDate = self.bookmarkedClip?.createdAt {
        if oldClipBookmarkDate.compare(newClipBookmarkDate) == NSComparisonResult.OrderedAscending {
          NSUserDefaults.standardUserDefaults().setObject(newClipBookmarkDate, forKey: kClipBookmarkDateKey)
          NSUserDefaults.standardUserDefaults().synchronize()
        }
      }
    }
  }

  // Storing these values is so that the VC can generate a fetch request
  // Once the third party FRC is gone, this can most likely be removed
  let predicate: NSPredicate
  let sortDescriptors: [SortDescriptor]

  // MARK: Initializers

  init(type: TimelineType) {
    self.type = type
    sortDescriptors = [SortDescriptor(property: "createdAt", ascending: true)]
    switch type {
    case .Home:
      predicate = NSPredicate(value: true)
    case .User(let userID):
      predicate = NSPredicate(format: "user.id = %@", userID)
    }
    self.clips = Clip.findAll().filter(predicate).sorted(sortDescriptors)
  }

  // MARK: Internal

  func clipsIncludingAndAfterClip(clip: Clip) -> Slice<Results<ActiveModel>> {
    guard let clipIndex = clips.indexOf(clip) else { return clips[clips.startIndex..<clips.endIndex] }
    return clips[clipIndex..<clips.endIndex]
  }

  func clipsAfterClip(clip: Clip) -> Slice<Results<ActiveModel>> {
    let clips = clipsIncludingAndAfterClip(clip)
    return clips[(clips.startIndex + 1)..<clips.endIndex]
  }
}

// MARK: - TimelineType
enum TimelineType {
  case Home
  case User(userID: String)
}