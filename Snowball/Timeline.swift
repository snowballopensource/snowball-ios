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
  var bookmarkedClip: Clip? {
    return clips.last as? Clip
  }

  // MARK: Initializers

  init(type: TimelineType) {
    self.type = type
    switch type {
    case .Home:
      self.clips = Clip.findAll().sorted("createdAt", ascending: true)
    }
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
}