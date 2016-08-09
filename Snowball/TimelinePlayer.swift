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

  // MARK: Properties

  var dataSource: TimelinePlayerDataSource?
  var delegate: TimelinePlayerDelegate?

  private let currentItemKeyPath = "currentItem"

  private var currentClip: Clip? {
    return (currentItem as? ClipPlayerItem)?.clip
  }

  // MARK: Initializers

  override init() {
    super.init()
    addObserver(self, forKeyPath: currentItemKeyPath, options: [.Old, .New], context: nil)
  }

  deinit {
    removeObserver(self, forKeyPath: currentItemKeyPath)
  }

  // MARK: Internal

  func playClip(clip: Clip) {
    safelyEnqueueClip(clip)
    play()
  }

  func next() {
    advanceToNextItem()
  }

  func previous() {
    for item in items() {
      if currentItem != item {
        removeItem(item)
      }
    }
    if let currentClip = currentClip, let previousClip = clipBeforeClip(currentClip) {
      safelyEnqueueClip(previousClip)
    }
    advanceToNextItem()
  }

  // MARK: Private

  private func clipAfterClip(clip: Clip) -> Clip? {
    if let currentClip = currentClip, let currentClipIndex = dataSource?.timelinePlayer(self, indexOfClip: currentClip) {
      let nextClipIndex = currentClipIndex + 1
      if nextClipIndex < dataSource?.numberOfClipsInTimelinePlayer(self) {
        return dataSource?.timelinePlayer(self, clipAtIndex: nextClipIndex)
      }
    }
    return nil
  }

  private func clipBeforeClip(clip: Clip) -> Clip? {
    if let currentClip = currentClip, let currentClipIndex = dataSource?.timelinePlayer(self, indexOfClip: currentClip) {
      let previousClipIndex = currentClipIndex - 1
      if 0...(dataSource?.numberOfClipsInTimelinePlayer(self) ?? 0) ~= previousClipIndex {
        return dataSource?.timelinePlayer(self, clipAtIndex: previousClipIndex)
      }
    }
    return nil
  }

  private func safelyEnqueueClip(clip: Clip) {
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

    if canEnqueueClip(clip) {
      enqueueClip(clip)
    }
  }

  private func ensureEnoughClipsInQueue() {
    if let currentClip = currentClip, let clipIndex = dataSource?.timelinePlayer(self, indexOfClip: currentClip) {
      let numberOfClips = dataSource?.numberOfClipsInTimelinePlayer(self)
      for i in clipIndex..<clipIndex + 3 where i < numberOfClips {
        if let clip = dataSource?.timelinePlayer(self, clipAtIndex: i) {
          safelyEnqueueClip(clip)
        }
      }
    }
  }

  private func onClipChange(oldClip: Clip?, newClip: Clip?) {
    if let oldClip = oldClip, newClip = newClip {
     delegate?.timelinePlayer(self, didTransitionFromClip: oldClip, toClip: newClip)
    } else if let oldClip = oldClip {
      delegate?.timelinePlayer(self, didEndPlaybackWithLastClip: oldClip)
    } else if let newClip = newClip {
      delegate?.timelinePlayer(self, willBeginPlaybackWithFirstClip: newClip)
    }

    if newClip != nil {
      ensureEnoughClipsInQueue()
    }
  }

  // MARK: KVO

  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if keyPath == currentItemKeyPath {
      guard let change = change else { return }
      let oldClip = (change[NSKeyValueChangeOldKey] as? ClipPlayerItem)?.clip
      let newClip = (change[NSKeyValueChangeNewKey] as? ClipPlayerItem)?.clip
      onClipChange(oldClip, newClip: newClip)
    } else {
      super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
    }
  }
}

// MARK: - TimelinePlayerDataSource
protocol TimelinePlayerDataSource {
  func numberOfClipsInTimelinePlayer(player: TimelinePlayer) -> Int
  func timelinePlayer(player: TimelinePlayer, clipAtIndex index: Int) -> Clip
  func timelinePlayer(player: TimelinePlayer, indexOfClip clip: Clip) -> Int?
}

// MARK: - TimelinePlayerDataSource
protocol TimelinePlayerDelegate {
//  func timelinePlayerShouldBeginPlayback(timelinePlayer: TimelinePlayer) -> Bool
  func timelinePlayer(timelinePlayer: TimelinePlayer, willBeginPlaybackWithFirstClip clip: Clip)
  func timelinePlayer(timelinePlayer: TimelinePlayer, didTransitionFromClip fromClip: Clip, toClip: Clip)
  func timelinePlayer(timelinePlayer: TimelinePlayer, didEndPlaybackWithLastClip clip: Clip)
}

// MARK: - ClipPlayerItem
class ClipPlayerItem: AVPlayerItem {
  let clip: Clip

  init(clip: Clip) {
    self.clip = clip
    super.init(asset: AVAsset(URL: clip.videoURL), automaticallyLoadedAssetKeys: ["tracks", "duration"])
  }
}