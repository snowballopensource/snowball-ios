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

  convenience init(clip: Clip) {
    self.init(URL: clip.videoURL)
    self.clip = clip
  }
}

class TimelinePlayer: AVPlayer {
  var timeline: Timeline?
  var delegate: TimelinePlayerDelegate?
  private(set) var currentClip: Clip? = nil {
    didSet {
      if currentClip == nil {
        pause()
        replaceCurrentItemWithPlayerItem(nil)
      } else {
        let playerItem = ClipPlayerItem(clip: currentClip!)
        registerPlayerItemForNotifications(playerItem)
        replaceCurrentItemWithPlayerItem(playerItem)
        play()
      }
      if oldValue == nil && currentClip == nil { return }
      if oldValue == nil && currentClip != nil {
        delegate?.timelinePlayer(self, didBeginPlayingWithClip: currentClip!)
      } else if oldValue != nil && currentClip != nil {
        delegate?.timelinePlayer(self, didTransitionFromClip: oldValue!, toClip: currentClip!)
      } else if oldValue != nil && currentClip == nil {
        delegate?.timelinePlayer(self, didEndPlayingLastClip: oldValue!)
      }
    }
  }
  var playing: Bool {
    if rate != 0 && error == nil {
      return true
    }
    return false
  }

  // MARK: - Initializers

  override init() {
    super.init()
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  // MARK: - Internal

  func play(clip: Clip) {
    currentClip = clip
  }

  func stop() {
    currentClip = nil
  }

  // MARK: - Private

  private func registerPlayerItemForNotifications(playerItem: ClipPlayerItem) {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidPlayToEndTime:", name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
  }

  @objc private func playerItemDidPlayToEndTime(notification: NSNotification) {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: notification.name, object: notification.object)
    if let playerItem = notification.object as? ClipPlayerItem {
      currentClip = timeline?.clipAfterClip(playerItem.clip)
    }
  }
}

protocol TimelinePlayerDelegate {
  func timelinePlayer(timelinePlayer: TimelinePlayer, didBeginPlayingWithClip clip: Clip)
  func timelinePlayer(timelinePlayer: TimelinePlayer, didTransitionFromClip fromClip: Clip, toClip: Clip)
  func timelinePlayer(timelinePlayer: TimelinePlayer, didEndPlayingLastClip lastClip: Clip)
}

class TimelinePlayerView: UIView {
  var player: AVPlayer {
    get {
      let playerLayer = layer as! AVPlayerLayer
      return playerLayer.player
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