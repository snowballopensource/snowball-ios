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

  let id = NSUUID().UUIDString
  let type: TimelineType
  let clips: Results<Clip>
  var currentPage = 0
  private let kClipBookmarkDateKey = "ClipBookmarkDate"
  var bookmarkedClip: Clip? {
    get {
      if type.allowsBookmark {
        let filteredClips = clips.filter("id != NULL")
        if let bookmarkDate = NSUserDefaults.standardUserDefaults().objectForKey(kClipBookmarkDateKey) as? NSDate {
          if let clipAfterBookmark = filteredClips.filter("createdAt > %@", bookmarkDate).first {
            return clipAfterBookmark
          }
          if let clipAtBookmark = filteredClips.filter("createdAt == %@", bookmarkDate).first {
            return clipAtBookmark
          }
        }
        return filteredClips.first
      }
      return nil
    }
    set {
      if type.allowsBookmark {
        if let newClipBookmarkDate = newValue?.createdAt, let oldClipBookmarkDate = self.bookmarkedClip?.createdAt {
          if oldClipBookmarkDate.compare(newClipBookmarkDate) == NSComparisonResult.OrderedAscending {
            NSUserDefaults.standardUserDefaults().setObject(newClipBookmarkDate, forKey: kClipBookmarkDateKey)
            NSUserDefaults.standardUserDefaults().synchronize()
          }
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
      predicate = NSPredicate(format: "inHomeTimeline == %@", true)
    case .User(let userID):
      predicate = NSPredicate(format: "timelineID == %@ && user.id == %@", id, userID)
    }
    self.clips = Database.findAll(Clip).filter(predicate).sorted(sortDescriptors)
  }

  // MARK: Internal

  func clipsIncludingAndAfterClip(clip: Clip) -> Slice<Results<Clip>> {
    guard let clipIndex = clips.indexOf(clip) else { return clips[clips.startIndex..<clips.endIndex] }
    return clips[clipIndex..<clips.endIndex]
  }

  func clipsAfterClip(clip: Clip) -> Slice<Results<Clip>> {
    let clips = clipsIncludingAndAfterClip(clip)
    return clips[(clips.startIndex + 1)..<clips.endIndex]
  }

  func requestRefreshOfClips(completion: (() -> Void)? = nil) {
    currentPage = 1
    requestClipsOnCurrentPage(completion)
  }

  func requestNextPageOfClips(completion: (() -> Void)?) {
    currentPage++
    requestClipsOnCurrentPage(completion)
  }

  // MARK: Private

  private func requestClipsOnCurrentPage(completion: (() -> Void)?) {
    let requestedPage = currentPage
    let route: SnowballRoute = {
      switch self.type {
      case .Home: return SnowballRoute.GetClipStream(page: requestedPage)
      case .User(let userID): return SnowballRoute.GetClipStreamForUser(userID: userID, page: requestedPage)
      }
    }()
    SnowballAPI.requestObjects(route,
      eachObjectBeforeSave: { (clip: Clip) in
        clip.timelineID = self.id
        if self.type == .Home {
          clip.inHomeTimeline = true
        }
      },
      completion: { (response: ObjectResponse<[Clip]>) in
        switch response {
        case .Success(let clips):
          if self.type == .Home && requestedPage == 1 {
            self.deleteClipsNotInClips(clips)
          }
        case .Failure(let error): print(error) // TODO: Handle error
        }
        completion?()
    })
  }

  private func deleteClipsNotInClips(clips: [Clip]) {
    var clipIDs = [String]()
    for clip in clips {
      guard let clipID = clip.id else { break }
      clipIDs.append(clipID)
    }
    let clipsToDelete = Database.findAll(Clip).filter("NOT id IN %@", clipIDs)
    Database.performTransaction {
      Database.realm.deleteWithNotification(clipsToDelete)
    }
  }
}

// MARK: - TimelineType
enum TimelineType {
  case Home
  case User(userID: String)

  // MARK: Properties

  var allowsBookmark: Bool {
    if self == .Home {
      return true
    }
    return false
  }
}

extension TimelineType: Equatable {}
func ==(lhs: TimelineType, rhs: TimelineType) -> Bool {
  switch (lhs, rhs) {
  case (.Home, .Home): return true
  case (.User(let lhsUserID), .User(let rhsUserID)): return lhsUserID == rhsUserID
  default: return false
  }
}