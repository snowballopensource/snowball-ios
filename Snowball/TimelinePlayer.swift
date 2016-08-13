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

  private let loadingQueue: NSOperationQueue = {
    let queue = NSOperationQueue()
    queue.maxConcurrentOperationCount = 1
    return queue
  }()

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
    play()
    if let _ = currentClip {
      removeItemsExceptCurrentItem()
      safelyEnqueueClip(clip) {
        self.advanceToNextItem()
      }
    } else {
      safelyEnqueueClip(clip)
    }
  }

  func next() {
    advanceToNextItem()
  }

  func previous() {
    removeItemsExceptCurrentItem()
    if let currentClip = currentClip, let previousClip = clipBeforeClip(currentClip) {
      safelyEnqueueClip(previousClip) {
        self.advanceToNextItem()
      }
    }
  }

  func stop() {
    pause()
    loadingQueue.cancelAllOperations()
    removeAllItems()
  }

  // MARK: Private

  private func removeItemsExceptCurrentItem() {
    for item in items() {
      if currentItem != item {
        removeItem(item)
      }
    }
  }

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

  private func safelyEnqueueClip(clip: Clip, completion: (() -> Void)? = nil) {
    func canEnqueueClip(clip: Clip) -> Bool {
      var shouldEnqueueClip = true
      for queueOperation in loadingQueue.operations {
        if let queueOperation = queueOperation as? ClipLoadingOperation {
          if clip == queueOperation.clip { shouldEnqueueClip = false }
        }
      }
      for queuedItem in items() {
        if let queuedItem = queuedItem as? ClipPlayerItem {
          if clip == queuedItem.clip { shouldEnqueueClip = false }
        }
      }
      return shouldEnqueueClip
    }

    func enqueueClip(clip: Clip, completion: (() -> Void)? = nil) {
      let loadingOperation = ClipLoadingOperation(clip: clip) { playerItem in
        self.insertItem(playerItem, afterItem: nil)
        completion?()
      }
      loadingQueue.addOperation(loadingOperation)
    }

    if canEnqueueClip(clip) {
      enqueueClip(clip, completion: completion)
    }
  }

  private func ensureEnoughClipsInQueue() {
    let queue = dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.rawValue), 0)
    dispatch_async(queue) {
      if let currentClip = self.currentClip, let clipIndex = self.dataSource?.timelinePlayer(self, indexOfClip: currentClip) {
        let numberOfClips = self.dataSource?.numberOfClipsInTimelinePlayer(self)
        for i in clipIndex..<clipIndex + 3 where i < numberOfClips {
          if let clip = self.dataSource?.timelinePlayer(self, clipAtIndex: i) {
            self.safelyEnqueueClip(clip)
          }
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

  init(clip: Clip, asset: AVAsset) {
    self.clip = clip
    super.init(asset: asset, automaticallyLoadedAssetKeys: nil)
  }
}

// MARK: - ClipLoadingOperation
class ClipLoadingOperation: NSOperation {
  // NSOperations suck. Here's some help:
  // https://github.com/robertmryan/Operation-Test-Swift/tree/master/OperationTestSwift

  // MARK: Properties

  let clip: Clip
  private let onSuccess: (playerItem: ClipPlayerItem) -> Void

  override var asynchronous: Bool { return true }

  private var _executing = false
  override var executing: Bool {
    get {
      return _executing
    }
    set {
      willChangeValueForKey("isExecuting")
      _executing = newValue
      didChangeValueForKey("isExecuting")
    }
  }

  private var _finished = false
  override var finished: Bool {
    get {
      return _finished
    }
    set {
      willChangeValueForKey("isFinished")
      _finished = newValue
      didChangeValueForKey("isFinished")
    }
  }

  // MARK: Initializers

  init(clip: Clip, onSuccess: (playerItem: ClipPlayerItem) -> Void) {
    self.clip = clip
    self.onSuccess = onSuccess
    super.init()
  }

  // MARK: NSOperation

  override func start() {
    executing = true
    unlessCancelled {
      self.main()
    }
  }

  override func main() {
    let asset = AVAsset(URL: clip.videoURL)
    asset.loadValuesAsynchronouslyForKeys(["duration", "tracks"]) {
      self.unlessCancelled {
        self.onSuccess(playerItem: ClipPlayerItem(clip: self.clip, asset: asset))
        self.completeOperation()
      }
    }
  }

  // MARK: Private

  private func completeOperation() {
    executing = false
    finished = true
  }

  private func unlessCancelled(block: () -> Void) {
    if cancelled {
      completeOperation()
      return
    } else {
      block()
    }
  }
}