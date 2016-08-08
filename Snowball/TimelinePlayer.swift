//
//  TimelinePlayer.swift
//  Snowball
//
//  Created by James Martinez on 8/8/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import AVFoundation
import Foundation

class TimelinePlayer: AVQueuePlayer {
  var dataSource: TimelinePlayerDataSource?

  private var previousClipIndex: Int? {
    if let currentClip = currentClip, let currentClipIndex = dataSource?.timelinePlayer(self, indexOfClip: currentClip) {
      let previousClipIndex = currentClipIndex - 1
      if 0...(dataSource?.numberOfClipsInTimelinePlayer(self) ?? 0) ~= previousClipIndex {
        return previousClipIndex
      }
    }
    return nil
  }

  private var nextClipIndex: Int? {
    if let currentClip = currentClip, let currentClipIndex = dataSource?.timelinePlayer(self, indexOfClip: currentClip) {
      let nextClipIndex = currentClipIndex + 1
      if nextClipIndex < dataSource?.numberOfClipsInTimelinePlayer(self) {
        return nextClipIndex
      }
    }
    return nil
  }

  private var previousClip: Clip? {
    if let previousClipIndex = previousClipIndex {
      return dataSource?.timelinePlayer(self, clipAtIndex: previousClipIndex)
    }
    return nil
  }

  private var nextClip: Clip? {
    if let nextClipIndex = nextClipIndex {
      return dataSource?.timelinePlayer(self, clipAtIndex: nextClipIndex)
    }
    return nil
  }

  private var currentClip: Clip? {
    return (currentItem as? ClipPlayerItem)?.clip
  }

  func playClip(clip: Clip) {
    safelyEnqueueClipAndEnsureFullBuffer(clip)
    play()
  }

  func next() {
    if let nextClip = nextClip {
      safelyEnqueueClipAndEnsureFullBuffer(nextClip)
    }
    advanceToNextItem()
  }

  func previous() {
    for item in items() {
      if currentItem != item {
        removeItem(item)
      }
    }
    if let previousClip = previousClip {
      safelyEnqueueClipAndEnsureFullBuffer(previousClip)
    }
    advanceToNextItem()
  }

  private func safelyEnqueueClipAndEnsureFullBuffer(clip: Clip) {
    func canEnqueueClip(clip: Clip) -> Bool {
      var shouldEnqueueClip = true
      for queuedItem in items() {
        if let queuedItem = queuedItem as? ClipPlayerItem {
          if clip == queuedItem.clip { shouldEnqueueClip = false }
        }
      }
      return shouldEnqueueClip
    }

    func enqueueClip(clip: Clip) {
      let playerItem = ClipPlayerItem(clip: clip)
      let lastPlayerItem = items().last
      if canInsertItem(playerItem, afterItem: lastPlayerItem) {
        insertItem(playerItem, afterItem: lastPlayerItem)
      }
    }

    if let clipIndex = dataSource?.timelinePlayer(self, indexOfClip: clip) {
      let numberOfClips = dataSource?.numberOfClipsInTimelinePlayer(self)
      for i in clipIndex..<clipIndex + 3 where i < numberOfClips {
        if let clip = dataSource?.timelinePlayer(self, clipAtIndex: i) {
          if canEnqueueClip(clip) {
            enqueueClip(clip)
          }
        }
      }
    }
  }
}

// MARK: - TimelinePlayerDataSource
protocol TimelinePlayerDataSource {
  func numberOfClipsInTimelinePlayer(player: TimelinePlayer) -> Int
  func timelinePlayer(player: TimelinePlayer, clipAtIndex index: Int) -> Clip
  func timelinePlayer(player: TimelinePlayer, indexOfClip clip: Clip) -> Int?
}

// MARK: - ClipPlayerItem
class ClipPlayerItem: AVPlayerItem {
  let clip: Clip

  init(clip: Clip) {
    self.clip = clip
    super.init(asset: AVAsset(URL: clip.videoURL), automaticallyLoadedAssetKeys: ["duration"])
  }
}