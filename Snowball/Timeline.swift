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
      delegate?.timelineClipsDidChange()
    }
  }
  var pendingClips: [Clip] {
    var pendingClips = self.clips.filter { (clip) -> Bool in
      if clip.state == ClipState.Pending || clip.state == ClipState.Uploading {
        return true
      }
      return false
    }
    return pendingClips
  }
  private let kClipBookmarkDateKey = "ClipBookmarkDate"
  var bookmarkedClip: Clip? {
    get {
      let clipBookmarkDate = NSUserDefaults.standardUserDefaults().objectForKey(kClipBookmarkDateKey) as? NSDate
      if let bookmarkDate = clipBookmarkDate {
        for clip in clips {
          if let clipCreatedAt = clip.createdAt {
            if bookmarkDate.compare(clipCreatedAt) == NSComparisonResult.OrderedAscending {
              return clip
            }
          }
          // If we get to the last clip and nothing has returned yet, then run this logic to check for deleted bookmarked clip OR user has not returned
          if let lastClip = clips.last {
            if let lastClipCreatedAt = lastClip.createdAt {
              if clip == lastClip {
                // If bookmark date is EARLIER than the first clip, user has not returned in some time
                if let firstClip = clips.first {
                  if let firstClipCreatedAt = firstClip.createdAt {
                    if bookmarkDate.compare(firstClipCreatedAt) == NSComparisonResult.OrderedAscending {
                      return firstClip
                    }
                  }
                }
                // Bookmarked clip was probably deleted, return last clip
                return lastClip
              }
            }
          }
        }
      }
      return clips.first
    }
    set {
      if let newClipBookmarkDate = newValue?.createdAt {
        if let oldClipBookmarkDate = self.bookmarkedClip?.createdAt {
          if oldClipBookmarkDate.compare(newClipBookmarkDate) == NSComparisonResult.OrderedAscending {
            NSUserDefaults.standardUserDefaults().setObject(newClipBookmarkDate, forKey: kClipBookmarkDateKey)
            NSUserDefaults.standardUserDefaults().synchronize()
          }
        }
      }
    }
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

  func requestHomeTimeline(completion: (error: NSError?) -> Void) {
    API.request(Router.GetClipStream).responseJSON { (request, response, JSON, error) in
      if let error = error {
        completion(error: error)
      } else if let JSON = JSON as? [AnyObject] {
        // Handle clips that were captured before the timeline loads from server...
        self.clips = Clip.importJSON(JSON) + self.pendingClips
        completion(error: nil)
      }
    }
  }
}

protocol TimelineDelegate {
  func timelineClipsDidChange()
}