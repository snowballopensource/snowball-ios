//
//  TimelinePlayer.swift
//  Snowball
//
//  Created by James Martinez on 7/30/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit

class ClipPlayerItem: AVPlayerItem {
  var clip: Clip!

  convenience init(url: NSURL, clip: Clip) {
    self.init(URL: url)
    self.clip = clip
  }
}

class TimelinePlayer: AVQueuePlayer {
  var timeline: Timeline?
  var delegate: TimelinePlayerDelegate?
  var playing = false
  var currentClip: Clip? {
    didSet {
      let newValue = currentClip
      if oldValue == nil && newValue == nil { return }
      if oldValue == newValue { return }
      if oldValue == nil && newValue != nil {
        delegate?.timelinePlayer(self, didBeginPlayingWithClip: newValue!)
      } else if oldValue != nil && newValue != nil {
        delegate?.timelinePlayer(self, didTransitionFromClip: oldValue!, toClip: newValue!)
      } else if oldValue != nil && newValue == nil {
        if playing {
          if let lastClip = timeline?.clips.last {
            if oldValue == lastClip {
              playing = false
              delegate?.timelinePlayer(self, didEndPlayingWithLastClip: oldValue!)
            }
          }
        } else {
          // We stopped playback manually..
          delegate?.timelinePlayer(self, didEndPlayingWithLastClip: oldValue!)
        }
      }
      if newValue != nil {
        delegate?.timelinePlayerDidBeginBuffering(self)
      }
    }
  }
  private let currentItemKeyPath = "currentItem"

  // MARK: - Initializers

  override init() {
    super.init()
    addObserver(self, forKeyPath: currentItemKeyPath, options: .New, context: nil)
    addBoundaryTimeObserverForTimes([NSValue(CMTime: CMTime(value: 1, timescale: 30))], queue: dispatch_get_main_queue()) {
      self.delegate?.timelinePlayerDidEndBuffering(self)
    }
  }

  deinit {
    removeObserver(self, forKeyPath: currentItemKeyPath)
  }

  // MARK: - Internal

  func play(clip: Clip) {
    if playing { return }
    if let delegate = delegate {
      if delegate.timelinePlayer(self, shouldBeginPlayingWithClip: clip) {
        playing = true
        currentClip = clip
        preloadTimelineStartingWithClip(clip) {
          self.play()
        }
      }
    }
  }

  func stop() {
    playing = false
    currentClip = nil
    pause()
    removeAllItems()
  }

  func next() {
    guard let currentClip = currentClip else { return }
    guard let nextClip = timeline?.clipAfterClip(currentClip) else { return }
    self.currentClip = nextClip
    advanceToNextItem()
    play()
  }

  func previous() {
    guard let currentClip = currentClip else { return }
    guard let previousClip = timeline?.clipBeforeClip(currentClip) else { return }
    self.currentClip = previousClip
    pause()
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
      let itemsToRemove = self.items().filter { $0 != self.currentItem }
      for item in itemsToRemove {
        self.removeItem(item)
      }
      self.preloadTimelineStartingWithClip(previousClip) {
        dispatch_async(dispatch_get_main_queue()) {
          self.advanceToNextItem()
          self.play()
        }
      }
    }
  }

  // MARK: - KVO

  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String: AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if keyPath == currentItemKeyPath {
      guard let change = change else { return }
      let newValue = change[NSKeyValueChangeNewKey] as? ClipPlayerItem
      currentClip = newValue?.clip
    }
  }

  // MARK: - Private

  private func preloadTimelineStartingWithClip(clip: Clip, firstClipFinished: (Void -> Void)?) {
    guard let timeline = timeline else { return }
    let clips = [clip] + timeline.clipsAfterClip(clip)
    ClipDownloader.loadClips(clips) { (preloadedClip, cacheURL, error) -> Void in
      if !self.playing { return }
      error?.alertUser()
      if let url = cacheURL {
        let playerItem = ClipPlayerItem(url: url, clip: preloadedClip)
        self.insertItem(playerItem, afterItem: self.items().last)
      }
      if preloadedClip == clip { firstClipFinished?() }
    }
  }
}

protocol TimelinePlayerDelegate {
  func timelinePlayer(timelinePlayer: TimelinePlayer, shouldBeginPlayingWithClip clip: Clip) -> Bool
  func timelinePlayer(timelinePlayer: TimelinePlayer, didBeginPlayingWithClip clip: Clip)
  func timelinePlayer(timelinePlayer: TimelinePlayer, didEndPlayingWithLastClip lastClip: Clip)
  func timelinePlayer(timelinePlayer: TimelinePlayer, didTransitionFromClip fromClip: Clip, toClip: Clip)
  func timelinePlayerDidBeginBuffering(timelinePlayer: TimelinePlayer)
  func timelinePlayerDidEndBuffering(timelinePlayer: TimelinePlayer)
}

class TimelinePlayerView: UIView {
  var player: AVPlayer {
    get {
      let playerLayer = layer as! AVPlayerLayer
      return playerLayer.player!
    }
    set {
      let playerLayer = layer as! AVPlayerLayer
      playerLayer.player = newValue
    }
  }

  // MARK: - Initializers

  convenience init() {
    self.init(frame: CGRectZero)
    let playerLayer = layer as! AVPlayerLayer
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
  }

  // MARK: - UIView

  override class func layerClass() -> AnyClass {
    return AVPlayerLayer.self
  }
}