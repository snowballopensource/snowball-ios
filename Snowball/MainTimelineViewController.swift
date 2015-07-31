//
//  MainTimelineViewController.swift
//  Snowball
//
//  Created by James Martinez on 7/28/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import UIKit

class MainTimelineViewController: TimelineViewController {

  // MARK: - TimelineViewController

  override func refresh() {
    timeline.requestHomeTimeline { (error) -> Void in
      if let error = error {
        println(error)
        // TODO: Display the error
      }
    }
  }

  override func stateForCellAtIndexPath(indexPath: NSIndexPath) -> ClipCollectionViewCellState {
    let clip = timeline.clips[indexPath.row]
    if let bookmarkedClip = timeline.bookmarkedClip {
      if clip == bookmarkedClip {
        return ClipCollectionViewCellState.Bookmarked
      }
    }
    return super.stateForCellAtIndexPath(indexPath)
  }
}

// MARK: - TimelineDelegate
extension MainTimelineViewController: TimelineDelegate {

  override func timelineClipsDidChange() {
    super.timelineClipsDidChange()

    if let pendingClip = timeline.pendingClips.last {
      scrollToClip(pendingClip, animated: false)
    } else if let bookmarkedClip = timeline.bookmarkedClip {
      scrollToClip(bookmarkedClip, animated: false)
    }
  }
}