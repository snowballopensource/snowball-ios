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
  var playing: Bool {
    return (currentItem != nil)
  }
  var currentClip: Clip? {
    let clipItem = currentItem as? ClipPlayerItem
    return clipItem?.clip
  }
  private let currentItemKeyPath = "currentItem"

  // MARK: - Initializers

  override init() {
    super.init()
    addObserver(self, forKeyPath: currentItemKeyPath, options: [.New, .Old], context: nil)
  }

  deinit {
    removeObserver(self, forKeyPath: currentItemKeyPath)
  }

  // MARK: - Internal

  func play(clip: Clip) {
    if playing { return }
    if let delegate = delegate {
      if delegate.timelinePlayer(self, shouldBeginPlayingWithClip: clip) {
        preloadTimelineStartingWithClip(clip) {
          self.play()
        }
      }
    }
  }

  func stop() {
    pause()
    removeAllItems()
  }

  func next() {
    advanceToNextItem()
    play()
  }

  func previous() {
    guard let currentClip = currentClip else { return }
    guard let previousClip = timeline?.clipBeforeClip(currentClip) else { return }
    pause()
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
      let itemsToRemove = self.items().filter { $0 != self.currentItem }
      for item in itemsToRemove {
        self.removeItem(item)
      }
      dispatch_async(dispatch_get_main_queue()) {
        self.preloadTimelineStartingWithClip(previousClip) {
          self.next()
        }
      }
    }
  }

  // MARK: - KVO

  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String: AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if keyPath == currentItemKeyPath {
      guard let change = change else { return }
      let oldValue = change[NSKeyValueChangeOldKey] as? ClipPlayerItem
      let newValue = change[NSKeyValueChangeNewKey] as? ClipPlayerItem
      if oldValue == nil && newValue == nil { return }
      if oldValue == nil && newValue != nil {
        delegate?.timelinePlayer(self, didBeginPlayingWithClip: newValue!.clip)
      } else if oldValue != nil && newValue != nil {
        delegate?.timelinePlayer(self, didTransitionFromClip: oldValue!.clip, toClip: newValue!.clip)
      } else if oldValue != nil && newValue == nil {
        delegate?.timelinePlayer(self, didEndPlayingWithLastClip: oldValue!.clip)
      }
    }
  }

  // MARK: - Private

  private func preloadTimelineStartingWithClip(clip: Clip, firstClipFinished: (Void -> Void)?) {
    guard let timeline = timeline else { return }
    let clips = [clip] + timeline.clipsAfterClip(clip)
    ClipDownloader.loadClips(clips) { (preloadedClip, cacheURL, error) -> Void in
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