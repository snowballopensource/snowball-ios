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

  private(set) var playing = false
  private let queueManager: PlayerQueueManager
  var delegate: TimelinePlayerDelegate?
  var currentClip: Clip? {
    didSet {
      let newValue = currentClip
      let noChanges = (oldValue == newValue)
      let beginningPlayback = (oldValue == nil && newValue != nil)
      let continuingPlayback = (oldValue != nil && newValue != nil)
      let endingPlayback = (oldValue != nil && newValue == nil)

      if noChanges { return }
      if beginningPlayback { delegate?.timelinePlayer(self, didBeginPlaybackWithFirstClip: newValue!) }
      if continuingPlayback { delegate?.timelinePlayer(self, didTransitionFromClip: oldValue!, toClip: newValue!) }
      if endingPlayback {
        stop()
        delegate?.timelinePlayer(self, didEndPlaybackWithLastClip: oldValue!)
      }
    }
  }

  private let currentItemKeyPath = "currentItem"

  // MARK: Initializers

  init(timeline: Timeline) {
    queueManager = PlayerQueueManager(timeline: timeline)
    super.init()
    queueManager.player = self
    addObserver(self, forKeyPath: currentItemKeyPath, options: .New, context: nil)
  }

  deinit {
    removeObserver(self, forKeyPath: currentItemKeyPath)
  }

  // MARK: KVO

  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if keyPath == currentItemKeyPath {
      guard let change = change else { return }
      let newPlayerItem = change[NSKeyValueChangeNewKey] as? ClipPlayerItem
      let buffering = (newPlayerItem == nil && queueManager.isLoadingAdditionalClips)
      if !buffering {
        currentClip = newPlayerItem?.clip
      }
    } else {
      super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
    }
  }

  // MARK: Internal

  func playWithFirstClip(clip: Clip) {
    let shouldBeginPlayback = delegate?.timelinePlayerShouldBeginPlayback(self) ?? false
    if shouldBeginPlayback {
      playing = true
      delegate?.timelinePlayer(self, willBeginPlaybackWithFirstClip: clip)
      queueManager.preparePlayerQueueToPlayClip(clip)
      play()
    }
  }

  func stop() {
    playing = false
    queueManager.cancelAllOperations()
    pause()
    removeAllItems()
  }

  func topOffQueue() {
    queueManager.ensurePlayerQueueToppedOff()
  }

  func skipToClip(clip: Clip) {
    pause()
    removeAllItemsExceptCurrentItem()
    queueManager.preparePlayerQueueToSkipToClip(clip) {
      self.advanceToNextItem()
      self.play()
    }
  }

  // MARK: Private

  func removeAllItemsExceptCurrentItem() {
    for item in items() {
      if item != currentItem {
        removeItem(item)
      }
    }
  }
}

// MARK: - TimelinePlayerDelegate
protocol TimelinePlayerDelegate {
  func timelinePlayerShouldBeginPlayback(timelinePlayer: TimelinePlayer) -> Bool
  func timelinePlayer(timelinePlayer: TimelinePlayer, willBeginPlaybackWithFirstClip clip: Clip)
  func timelinePlayer(timelinePlayer: TimelinePlayer, didBeginPlaybackWithFirstClip clip: Clip)
  func timelinePlayer(timelinePlayer: TimelinePlayer, didTransitionFromClip fromClip: Clip, toClip: Clip)
  func timelinePlayer(timelinePlayer: TimelinePlayer, didEndPlaybackWithLastClip clip: Clip)
}