//
//  TimelinePlayer.swift
//  Snowball
//
//  Created by James Martinez on 1/4/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import AVFoundation

class TimelinePlayer: AVQueuePlayer {

  // MARK: Properties

  fileprivate(set) var playing = false
  fileprivate let queueManager: PlayerQueueManager
  var delegate: TimelinePlayerDelegate?
  var currentClip: Clip? {
    didSet {
      let newValue = currentClip
      let noChanges = (oldValue == newValue)
      let beginningPlayback = (oldValue == nil && newValue != nil)
      let continuingPlayback = (oldValue != nil && newValue != nil)
      let endingPlayback = (oldValue != nil && newValue == nil)

      if noChanges { return }
      if beginningPlayback {
        playing = true
        delegate?.timelinePlayer(self, willBeginPlaybackWithFirstClip: newValue!)
        queueManager.preparePlayerQueueToBeginPlaybackWithClip(newValue!)
        play()
      }
      if continuingPlayback { delegate?.timelinePlayer(self, didTransitionFromClip: oldValue!, toClip: newValue!) }
      if endingPlayback {
        playing = false
        delegate?.timelinePlayer(self, didEndPlaybackWithLastClip: oldValue!)
        queueManager.cancelAllOperations()
        pause()
        removeAllItems()
      }
    }
  }

  fileprivate let currentItemKeyPath = "currentItem"

  // MARK: Initializers

  init(timeline: Timeline) {
    queueManager = PlayerQueueManager(timeline: timeline)
    super.init()
    queueManager.player = self
    addObserver(self, forKeyPath: currentItemKeyPath, options: .new, context: nil)
  }

  deinit {
    removeObserver(self, forKeyPath: currentItemKeyPath)
  }

  // MARK: KVO

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == currentItemKeyPath {
      guard let change = change else { return }
      let newPlayerItem = change[NSKeyValueChangeKey.newKey] as? ClipPlayerItem
      let buffering = (newPlayerItem == nil && queueManager.isLoadingAdditionalClips)
      if buffering {
        currentClip = queueManager.nextBufferingClip
      } else {
        currentClip = newPlayerItem?.clip
      }
    } else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
  }

  // MARK: Internal

  func playWithFirstClip(_ clip: Clip) {
    let shouldBeginPlayback = delegate?.timelinePlayerShouldBeginPlayback(self) ?? false
    if shouldBeginPlayback { currentClip = clip }
  }

  func stop() {
    currentClip = nil
  }

  func topOffQueue() {
    queueManager.ensurePlayerQueueToppedOff()
  }

  func skipToClip(_ clip: Clip) {
    pause()

    currentClip = clip

    removeAllItemsExceptCurrentItem()
    let itemsLeft = items().count
    queueManager.cancelAllOperations()
    queueManager.preparePlayerQueueToSkipToClip(clip) {
      // If we remove all items except current item, but current item was not done
      // loading yet, advancing to next item would skip over the clip we wanted to
      // skip to
      if itemsLeft > 0 {
        self.advanceToNextItem()
      }
      self.play()
    }
  }

  // MARK: Private

  func removeAllItemsExceptCurrentItem() {
    for item in items() {
      if item != currentItem {
        remove(item)
      }
    }
  }
}

// MARK: - TimelinePlayerDelegate
protocol TimelinePlayerDelegate {
  func timelinePlayerShouldBeginPlayback(_ timelinePlayer: TimelinePlayer) -> Bool
  func timelinePlayer(_ timelinePlayer: TimelinePlayer, willBeginPlaybackWithFirstClip clip: Clip)
  func timelinePlayer(_ timelinePlayer: TimelinePlayer, didTransitionFromClip fromClip: Clip, toClip: Clip)
  func timelinePlayer(_ timelinePlayer: TimelinePlayer, didEndPlaybackWithLastClip clip: Clip)
}
