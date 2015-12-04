//
//  Timeline.swift
//  Snowball
//
//  Created by James Martinez on 7/30/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Foundation

enum TimelineLoadingState {
  case Idle, Loading
}

class Timeline {
  var delegate: TimelineDelegate?
  var clips = [Clip]() {
    didSet {
      clips = sortClips(clips)
      ClipDownloader.downloadTimeline(self, withFirstClip: bookmarkedClip)
    }
  }
  var pendingClips: [Clip] {
    let pendingClips = self.clips.filter { (clip) -> Bool in
      if clip.state == ClipState.Default {
        return false
      }
      return true
    }
    return pendingClips
  }
  private let kClipBookmarkDateKey = "ClipBookmarkDate"
  var bookmarkedClip: Clip? {
    get {
      if let bookmarkDate = NSUserDefaults.standardUserDefaults().objectForKey(kClipBookmarkDateKey) as? NSDate {
        let filteredClips = clips.filter() { (clip) -> Bool in
          if clip.state == ClipState.Default {
            return true
          }
          return false
        }
        for clip in filteredClips {
          if let clipCreatedAt = clip.createdAt {
            if bookmarkDate.compare(clipCreatedAt) == NSComparisonResult.OrderedAscending {
              return clip
            }
          }
        }
        // If we finish looping through all the clips and nothing has returned yet, then
        // run this logic to check for deleted bookmarked clip OR user has not returned
        if let firstClip = filteredClips.first, let firstClipCreatedAt = firstClip.createdAt, let lastClip = filteredClips.last, let _ = lastClip.createdAt {
          // If bookmark date is EARLIER than the first clip, user has not returned in some time
          if bookmarkDate.compare(firstClipCreatedAt) == NSComparisonResult.OrderedAscending {
            return firstClip
          }
          // Bookmarked clip was probably deleted, return last clip that is not uploading, etc.
          if let lastFilteredClip = filteredClips.last {
            return lastFilteredClip
          }
        }
      }
      return clips.first
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
  private(set) var loadingState = TimelineLoadingState.Idle
  private(set) var currentPage = 0

  // MARK: - Internal

  func loadCachedClips() {
    let sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
    let size = 25
    var offset = Clip.count() - size
    if offset < 0 { offset = 0 }
    clips = Clip.findAll(limit: size, offset: offset, sortDescriptors: sortDescriptors) as! [Clip]
    delegate?.timelineClipsDidLoadFromCache()
  }

  func clipsAfterClip(clip: Clip) -> [Clip] {
    var afterClips = [Clip]()
    if let index = clips.indexOf(clip) {
      afterClips = Array(clips[index+1..<clips.count])
    }
    return afterClips
  }

  func clipAfterClip(clip: Clip) -> Clip? {
    return clipsAfterClip(clip).first
  }

  func clipBeforeClip(clip: Clip) -> Clip? {
    if let index = clips.indexOf(clip) {
      let previousIndex = index - 1
      if previousIndex >= 0 {
        return clips[previousIndex]
      }
    }
    return nil
  }

  func indexOfClip(clip: Clip) -> Int? {
    return clips.indexOf(clip)
  }

  func appendClip(clip: Clip) {
    insertClip(clip, atIndex: clips.count)
  }

  func insertClip(clip: Clip, atIndex index: Int) {
    insertClipWithoutNotification(clip, atIndex: index)
    delegate?.timeline(self, didInsertClipAtIndex: index)
  }

  func deleteClip(clip: Clip) {
    if let index = indexOfClip(clip) {
      deleteClipWithoutNotification(clip)
      delegate?.timeline(self, didDeleteClipAtIndex: index)
    }
  }

  func markClipAsUpdated(clip: Clip) {
    if let index = indexOfClip(clip) {
      delegate?.timeline(self, didUpdateClipAtIndex: index)
    }
  }

  func requestHomeTimeline(page page: Int, completion: (error: NSError?) -> Void) {
    currentPage = page
    requestTimelineWithRoute(.GetClipStream(page: page), isRefresh: (page == 1), completion: completion)
  }

  func requestUserTimeline(user: User, page: Int, completion: (error: NSError?) -> Void) {
    if let userID = user.id {
      currentPage = page
      requestTimelineWithRoute(.GetClipStreamForUser(userID: userID, page: page), isRefresh: (page == 1), completion: completion)
    }
  }

  // MARK: - Private

  private func sortClips(clips: [Clip]) -> [Clip] {
    return clips.sort { (leftClip, rightClip) -> Bool in
      guard let leftClipCreatedAt = leftClip.createdAt, rightClipCreatedAt = rightClip.createdAt else {
        return false
      }
      return leftClipCreatedAt.compare(rightClipCreatedAt) == NSComparisonResult.OrderedAscending
    }
  }

  private func insertClipWithoutNotification(clip: Clip, atIndex index: Int) {
    clips.insert(clip, atIndex: index)
  }

  private func deleteClipWithoutNotification(clip: Clip) {
    if let index = indexOfClip(clip) {
      clips.removeAtIndex(index)
      clip.deleteObject()
      do { try CoreDataStack.defaultStack.mainQueueManagedObjectContext.save() } catch {}
    }
  }

  func requestTimelineWithRoute(route: Router, isRefresh: Bool, completion: (error: NSError?) -> Void) {
    loadingState = .Loading
    SnowballAPI.requestObjects(route) { (response: ObjectResponse<[Clip]>) in
      switch response {
      case .Success(let clips):
        if isRefresh {
          self.performPostRefreshMergeWithNewClips(clips)
        } else {
          self.performPreviousPageMergeWithNewClips(clips)
        }
        do { try self.clips.first?.managedObjectContext?.save() } catch {}
        completion(error: nil)
      case .Failure(let error):
        completion(error: error)
      }
      self.loadingState = .Idle
    }
  }

  private func performPostRefreshMergeWithNewClips(newClips: [Clip]) {
    let sortedNewClips = sortClips(newClips)

    let cacheClips = NSMutableOrderedSet(array: clips)
    let serverClips = NSMutableOrderedSet(array: sortedNewClips)
    let pendingClips = NSMutableOrderedSet(array: clips.filter({ !$0.isOnServer }))

    let clipsToDeleteSet = cacheClips.mutableCopy()
    clipsToDeleteSet.minusOrderedSet(serverClips)
    clipsToDeleteSet.minusOrderedSet(pendingClips)
    let clipsToDelete = clipsToDeleteSet.array as! [Clip]

    let clipsToInsertSet = serverClips.mutableCopy()
    clipsToInsertSet.minusOrderedSet(cacheClips)
    let clipsToInsert = clipsToInsertSet.array as! [Clip]

    var deleteIndexes = [Int]()
    for clip in clipsToDelete {
      if let index = clips.indexOf(clip) {
        deleteIndexes.append(index)
        deleteClipWithoutNotification(clip)
      }
    }

    var insertIndexes = [Int]()
    for clip in clipsToInsert {
      if let index = sortedNewClips.indexOf(clip) {
        insertIndexes.append(index)
        insertClipWithoutNotification(clip, atIndex: index)
      }
    }

    delegate?.timeline(self, didInsertClipsAtIndexes: insertIndexes, didDeleteClipsAtIndexes: deleteIndexes)
  }

  private func performPreviousPageMergeWithNewClips(newClips: [Clip]) {
    for clip in newClips {
      insertClip(clip, atIndex: clips.count)
    }
  }
}

protocol TimelineDelegate {
  func timelineClipsDidLoadFromCache()
  func timeline(timeline: Timeline, didUpdateClipAtIndex index: Int)
  func timeline(timeline: Timeline, didInsertClipAtIndex index: Int)
  func timeline(timeline: Timeline, didDeleteClipAtIndex index: Int)
  func timeline(timeline: Timeline, didInsertClipsAtIndexes insertIndexes: [Int], didDeleteClipsAtIndexes deleteIndexes: [Int])
}