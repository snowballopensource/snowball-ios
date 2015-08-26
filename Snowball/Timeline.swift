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
      ClipPreloader.preloadTimeline(self, withFirstClip: bookmarkedClip)
    }
  }
  var pendingClips: [Clip] {
    var pendingClips = self.clips.filter { (clip) -> Bool in
      if clip.state == ClipState.PendingUpload || clip.state == ClipState.Uploading {
        return true
      }
      return false
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
        if let firstClip = filteredClips.first, let firstClipCreatedAt = firstClip.createdAt, let lastClip = filteredClips.last, let lastClipCreatedAt = lastClip.createdAt {
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

  // MARK: - Initializers

  init() {
    let sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
    let size = 20
    var offset = Clip.count() - size
    if offset < 0 { offset = 0 }
    let predicate = NSPredicate(format: "stateString == %@ || stateString == nil", ClipState.Default.rawValue)
    clips = Clip.findAll(predicate: predicate, limit: size, offset: offset, sortDescriptors: sortDescriptors) as! [Clip]
  }

  // MARK: - Internal

  func clipAfterClip(clip: Clip) -> Clip? {
    if let index = find(clips, clip) {
      let nextIndex = index + 1
      if nextIndex < clips.count {
        return clips[nextIndex]
      }
    }
    return nil
  }

  func clipBeforeClip(clip: Clip) -> Clip? {
    if let index = find(clips, clip) {
      let previousIndex = index - 1
      if previousIndex >= 0 {
        return clips[previousIndex]
      }
    }
    return nil
  }

  func indexOfClip(clip: Clip) -> Int? {
    return find(clips, clip)
  }

  func appendClip(clip: Clip) {
    insertClip(clip, atIndex: clips.count)
  }

  func insertClip(clip: Clip, atIndex index: Int) {
    insert(&clips, clip, atIndex: index)
    delegate?.timeline(self, didInsertClip: clip, atIndex: index)
  }

  func deleteClip(clip: Clip) {
    if let index = indexOfClip(clip) {
      removeAtIndex(&clips, index)
      delegate?.timeline(self, didDeleteClip: clip, atIndex: index)
    }
  }

  func markClipAsUpdated(clip: Clip) {
    if let index = indexOfClip(clip) {
      delegate?.timeline(self, didUpdateClip: clip, atIndex: index)
    }
  }

  func requestHomeTimeline(completion: (error: NSError?) -> Void) {
    API.request(Router.GetClipStream).responseJSON { (request, response, JSON, error) in
      if let error = error {
        completion(error: error)
      } else if let JSON = JSON as? [AnyObject] {
        // Handle clips that were captured before the timeline loads from server...
        let clips = Clip.objectsFromJSON(JSON) as! [Clip]
        clips.first?.managedObjectContext?.save(nil)
        self.clips = clips + self.pendingClips
        self.delegate?.timelineClipsDidLoad()
        completion(error: nil)
      }
    }
  }

  func requestUserTimeline(user: User, completion: (error: NSError?) -> Void) {
    if let userID = user.id {
      API.request(Router.GetClipStreamForUser(userID: userID)).responseJSON { (request, response, JSON, error) in
        if let error = error {
          completion(error: error)
        } else if let JSON = JSON as? [AnyObject] {
          self.clips = Clip.objectsFromJSON(JSON) as! [Clip]
          self.delegate?.timelineClipsDidLoad()
          completion(error: nil)
        }
      }
    }
  }
}

protocol TimelineDelegate {
  func timelineClipsDidLoad()
  func timeline(timeline: Timeline, didInsertClip clip: Clip, atIndex index: Int)
  func timeline(timeline: Timeline, didUpdateClip clip: Clip, atIndex index: Int)
  func timeline(timeline: Timeline, didDeleteClip clip: Clip, atIndex index: Int)
}