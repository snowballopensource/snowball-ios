//
//  Timeline.swift
//  Snowball
//
//  Created by James Martinez on 7/30/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Foundation

class Timeline {
  var delegate: TimelineDelegate?
  var clips = [Clip]() {
    didSet {
      clips = clips.sort { (leftClip, rightClip) -> Bool in
        guard let leftClipCreatedAt = leftClip.createdAt, rightClipCreatedAt = rightClip.createdAt else {
          return false
        }
        return leftClipCreatedAt.compare(rightClipCreatedAt) == NSComparisonResult.OrderedAscending
      }
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
    delegate?.timelineDidChangeClips(self, insertedClipIndexes: [index], deletedClipIndexes: [Int]())
  }

  func deleteClip(clip: Clip) {
    if let index = indexOfClip(clip) {
      deleteClipWithoutNotification(clip)
      delegate?.timelineDidChangeClips(self, insertedClipIndexes: [Int](), deletedClipIndexes: [index])
    }
  }

  func markClipAsUpdated(clip: Clip) {
    if let index = indexOfClip(clip) {
      delegate?.timeline(self, didUpdateClipAtIndex: index)
    }
  }

  func requestHomeTimeline(page page: Int, completion: (error: NSError?) -> Void) {
    requestTimelineWithRoute(.GetClipStream(page: page), completion: completion)
  }

  func requestUserTimeline(user: User, page: Int, completion: (error: NSError?) -> Void) {
    if let userID = user.id {
      requestTimelineWithRoute(.GetClipStreamForUser(userID: userID, page: page), completion: completion)
    }
  }

  // MARK: - Private

  func requestTimelineWithRoute(route: Router, completion: (error: NSError?) -> Void) {
    SnowballAPI.requestObjects(route) { (response: ObjectResponse<[Clip]>) in
      switch response {
      case .Success(let clips):
        self.mergeOldClipsWithNewClips(clips)
        do { try self.clips.first?.managedObjectContext?.save() } catch {}
        completion(error: nil)
      case .Failure(let error):
        completion(error: error)
      }
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

  private func mergeOldClipsWithNewClips(newClips: [Clip]) {
    let cacheClips = NSMutableOrderedSet(array: clips)
    let serverClips = NSMutableOrderedSet(array: newClips)

    let clipsToDeleteSet = cacheClips.mutableCopy()
    clipsToDeleteSet.minusOrderedSet(serverClips)
    let clipsToDelete = clipsToDeleteSet.array as! [Clip]

    let clipsToInsertSet = serverClips.mutableCopy()
    clipsToInsertSet.minusOrderedSet(cacheClips)
    let clipsToInsert = clipsToInsertSet.array as! [Clip]

    var deletedClipIndexes = [Int]()
    for clip in clipsToDelete {
      let index = clips.indexOf(clip)!
      deletedClipIndexes.append(index)
      deleteClipWithoutNotification(clip)
    }

    var insertedClipIndexes = [Int]()
    for clip in clipsToInsert {
      let index = newClips.indexOf(clip)!
      insertedClipIndexes.append(index)
      insertClipWithoutNotification(clip, atIndex: index)
    }

    delegate?.timelineDidChangeClips(self, insertedClipIndexes: insertedClipIndexes, deletedClipIndexes: deletedClipIndexes)
  }
}

protocol TimelineDelegate {
  func timelineClipsDidLoadFromCache()
  func timeline(timeline: Timeline, didUpdateClipAtIndex index: Int)
  func timelineDidChangeClips(timeline: Timeline, insertedClipIndexes: [Int], deletedClipIndexes: [Int])
}