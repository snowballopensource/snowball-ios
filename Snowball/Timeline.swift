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

  let id = UUID().uuidString
  let type: TimelineType
  let clips: Results<Clip>
  var clipPendingAcceptance: Clip? {
    return clips.filter("stateString == %@", ClipState.PendingAcceptance.rawValue).sorted(byKeyPath: "createdAt").last
  }
  var clipsNeedingAttention: Results<Clip> {
    return clips.filter("stateString == %@ || stateString == %@", ClipState.PendingAcceptance.rawValue, ClipState.UploadFailed.rawValue).sorted(byKeyPath: "createdAt")
  }
  var currentPage = 0
  private let kClipBookmarkDateKey = "ClipBookmarkDate"
  var bookmarkedClip: Clip? {
    get {
      if type.allowsBookmark {
        let filteredClips = clips.filter("id != NULL")
        if let bookmarkDate = UserDefaults.standard.object(forKey: kClipBookmarkDateKey) as? Date {
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
          if oldClipBookmarkDate.compare(newClipBookmarkDate as Date) == ComparisonResult.orderedAscending {
            UserDefaults.standard.set(newClipBookmarkDate, forKey: kClipBookmarkDateKey)
            UserDefaults.standard.synchronize()
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
    sortDescriptors = [SortDescriptor(keyPath: "stateString"), SortDescriptor(keyPath: "createdAt")]
    switch type {
    case .home:
      predicate = NSPredicate(format: "inHomeTimeline == %@", true as CVarArg)
    case .user(let userID):
      predicate = NSPredicate(format: "timelineID == %@ && user.id == %@", id, userID)
    }
    self.clips = Database.findAll(Clip.self).filter(predicate).sorted(by: sortDescriptors)
  }

  // MARK: Internal

  func clipBeforeClip(_ clip: Clip) -> Clip? {
    if let clipIndex = clips.index(of: clip) {
      let beforeClipIndex = clipIndex - 1
      if beforeClipIndex >= 0 {
        return clips[beforeClipIndex]
      }
    }
    return nil
  }

  func clipAfterClip(_ clip: Clip) -> Clip? {
    return clipsAfterClip(clip).first
  }

  func clipsIncludingAndAfterClip(_ clip: Clip) -> [Clip] {
    let clips = Array(self.clips)
    guard let index = clips.index(of: clip) else {
      return clips
    }
    return Array(clips.dropFirst(index))
  }

  func clipsAfterClip(_ clip: Clip) -> [Clip] {
    let clips = clipsIncludingAndAfterClip(clip)
    return Array(clips.dropFirst())
  }

  func requestRefreshOfClips(_ completion: (() -> Void)? = nil) {
    currentPage = 1
    requestClipsOnCurrentPage(completion)
  }

  func requestNextPageOfClips(_ completion: (() -> Void)?) {
    currentPage += 1
    requestClipsOnCurrentPage(completion)
  }

  // MARK: Private

  private func requestClipsOnCurrentPage(_ completion: (() -> Void)?) {
    let requestedPage = currentPage
    let route: SnowballRoute = {
      switch self.type {
      case .home: return SnowballRoute.getClipStream(page: requestedPage)
      case .user(let userID): return SnowballRoute.getClipStreamForUser(userID: userID, page: requestedPage)
      }
    }()
    SnowballAPI.requestObjects(route,
      beforeSaveEveryObject: { (clip: Clip) in
        clip.timelineID = self.id
        if self.type == .home {
          clip.inHomeTimeline = true
        }
      },
      completion: { (response: ObjectResponse<[Clip]>) in
        switch response {
        case .success(let clips):
          if self.type == .home && requestedPage == 1 {
            self.deleteClipsNotInClips(clips)
          }
        case .failure(let error): print(error) // TODO: Handle error
        }
        completion?()
    })
  }

  private func deleteClipsNotInClips(_ clips: [Clip]) {
    var clipIDs = [String]()
    for clip in clips {
      guard let clipID = clip.id else { break }
      clipIDs.append(clipID)
    }
    let clipsToDelete = Database.findAll(Clip.self).filter("NOT id IN %@", clipIDs).filter("stateString == %@", ClipState.Default.rawValue)
    Database.performTransaction {
      Database.realm.delete(clipsToDelete)
    }
  }
}

// MARK: - TimelineType
enum TimelineType {
  case home
  case user(userID: String)

  // MARK: Properties

  var allowsBookmark: Bool {
    if self == .home {
      return true
    }
    return false
  }
}

extension TimelineType: Equatable {}
func ==(lhs: TimelineType, rhs: TimelineType) -> Bool {
  switch (lhs, rhs) {
  case (.home, .home): return true
  case (.user(let lhsUserID), .user(let rhsUserID)): return lhsUserID == rhsUserID
  default: return false
  }
}
