//
//  ClipPlayer.swift
//  Snowball
//
//  Created by James Martinez on 3/2/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import AVFoundation

class ClipPlayer: AVQueuePlayer {

  // MARK: - Properties

  var delegate: ClipPlayerDelegate?

  var playing: Bool {
    if rate > 0 && error == nil {
      return true
    }
    return false
  }

  var currentClip: Clip?

  private var preloadQueue = ClipPreloadQueue()

  // MARK: - Initializers

  override init() {
    super.init()
    actionAtItemEnd = AVPlayerActionAtItemEnd.Advance
    preloadQueue.delegate = self
  }

  // MARK: - Internal

  func playClips(clips: [Clip]) {
    if !playing {
      if let clip = clips.first {
        play()
        currentClip = clip
        delegate?.playerWillBeginPlayback()
        delegate?.playerWillPlayClip(clip)
        preloadQueue.preloadClips(clips)
      }
    }
  }

  func stop() {
    stopWithoutNotifyingDelegate()
    delegate?.playerDidEndPlayback()
  }

  func restartPlaybackWithNewClips(clips: [Clip]) {
    if clips.count > 0 {
      stopWithoutNotifyingDelegate()
      playClipsWithoutNotifyingDelegate(clips)
    }
  }

  // MARK: - Private

  // TODO: THIS IS AN UGLY DUPLICATE!!!
  private func playClipsWithoutNotifyingDelegate(clips: [Clip]) {
    if !playing {
      if let clip = clips.first {
        play()
        currentClip = clip
        delegate?.playerWillPlayClip(clip)
        preloadQueue.preloadClips(clips)
      }
    }
  }

  private func stopWithoutNotifyingDelegate() {
    preloadQueue.cancelAllOperations()
    pause()
    removeAllItems()
    currentClip = nil
  }

  private func registerPlayerItemForNotifications(playerItem: ClipPlayerItem) {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidPlayToEndTime:", name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
  }

  @objc private func playerItemDidPlayToEndTime(notification: NSNotification) {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: notification.name, object: notification.object)
    if let clip = self.currentClip {
      let notificationPlayerItem = notification.object as! ClipPlayerItem
      if let notificationPlayerItem = notification.object as? ClipPlayerItem {
        if notificationPlayerItem.clip.id == clip.id {
          self.delegate?.clipDidPlayToEndTime(notificationPlayerItem.clip)
        }
        if let nextItem = itemAfterItem(notificationPlayerItem) {
          self.currentClip = nextItem.clip
          self.delegate?.playerWillPlayClip(nextItem.clip)
        }
      }
    }
  }

  private func itemAfterItem(item: ClipPlayerItem) -> ClipPlayerItem? {
    if self.items().count > 0 {
      let items = self.items() as NSArray
      let itemIndex = items.indexOfObject(item)
      let nextItemIndex = itemIndex + 1
      if nextItemIndex < items.count {
        return items[nextItemIndex] as? ClipPlayerItem
      }
    }
    return nil
  }
}

// MARK: -

extension ClipPlayer: ClipPreloadQueueDelegate {

  // MARK: - ClipPreloadQueueDelegate

  func videoReadyForClip(clip: Clip, cacheURL: NSURL) {
    let playerItem = ClipPlayerItem(clip: clip, asset: AVURLAsset(URL: cacheURL, options: nil))
    registerPlayerItemForNotifications(playerItem)
    insertItem(playerItem, afterItem: self.items().last as? AVPlayerItem)
  }
}

// MARK: -

protocol ClipPlayerDelegate {
  func playerWillBeginPlayback()
  func playerDidEndPlayback()
  func playerWillPlayClip(clip: Clip)
  func clipDidPlayToEndTime(clip: Clip)
}

// MARK: -

private class ClipPlayerItem: AVPlayerItem {

  // MARK: - Properties

  var clip: Clip!

  // MARK: - Initializers

  convenience init(clip: Clip, asset: AVAsset) {
    self.init(asset: asset)
    registerForNotifications()
    self.clip = clip
  }

  deinit {
    removeNotificationRegistration()
  }

  // MARK: - KVO

  private override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
    if keyPath == "playbackLikelyToKeepUp" {
      if !playbackLikelyToKeepUp {
        println("playback is unlikely to keep up")
      }
    }
  }

  // MARK: - Private

  private func registerForNotifications() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemPlaybackStalled:", name: AVPlayerItemPlaybackStalledNotification, object: self)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemFailedToPlayToEndTime:", name: AVPlayerItemFailedToPlayToEndTimeNotification, object: self)
    addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: NSKeyValueObservingOptions.New, context: nil)
  }

  private func removeNotificationRegistration() {
    NSNotificationCenter.defaultCenter().removeObserver(self)
    removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
  }

  @objc private func playerItemPlaybackStalled(notification: NSNotification) {
    println("player item stalled")
  }

  @objc private func playerItemFailedToPlayToEndTime(notification: NSNotification) {
    if let userInfo = notification.userInfo as? [String: AnyObject] {
      let error = userInfo[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? NSError
      error?.print("player item failed to play to end time")
    }
  }
}