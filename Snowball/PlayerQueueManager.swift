//
//  PlayerQueueManager.swift
//  Snowball
//
//  Created by James Martinez on 1/7/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import AVFoundation
import Foundation
import RealmSwift

class PlayerQueueManager {

  // MARK: Properties

  weak var player: AVQueuePlayer?
  private let queue: NSOperationQueue = {
    let queue = NSOperationQueue()
    queue.qualityOfService = .UserInitiated
    queue.maxConcurrentOperationCount = 1
    return queue
  }()
  private let desiredMaximumClipCount = 3

  // MARK: Internal

  // TODO: Rename, since it isn't always topping up, and includes 4? already in queue
  func topUpPlayerQueueWithClips(clips: Results<ActiveModel>, readyToPlayFirstClip: (() -> Void)? = nil) {
    let clipsEnqueuedCount = (player?.items().count ?? 0) + queue.operationCount
    let totalClipsCount = clips.count
    let bufferClipCount = (totalClipsCount >= desiredMaximumClipCount) ? desiredMaximumClipCount : totalClipsCount
    let countOfClipsToAdd = bufferClipCount - clipsEnqueuedCount
    if countOfClipsToAdd <= 0 { return }
    guard let clipsToEnqueue = Array(clips[clipsEnqueuedCount...(clipsEnqueuedCount + countOfClipsToAdd - 1)]) as? [Clip] else { return }
    enqueueClipsInPlayer(clipsToEnqueue, readyToPlayFirstClip: readyToPlayFirstClip)
  }

  // MARK: Private

  private func enqueueClipsInPlayer(clips: [Clip], readyToPlayFirstClip: (() -> Void)?) {
    guard let clip = clips.first else { return }
    enqueueClipInPlayer(clip)
    readyToPlayFirstClip?()
    var nextClips = clips
    nextClips.removeFirst()
    enqueueClipsInPlayer(nextClips, readyToPlayFirstClip: nil)
  }

  private func enqueueClipInPlayer(clip: Clip) {
    guard let playerItem = ClipPlayerItem(clip: clip) else { return }
    let loadPlayerItemOperation = LoadPlayerItemOperation(playerItem: playerItem)
    loadPlayerItemOperation.completionBlock = {
      dispatch_async(dispatch_get_main_queue()) {
        self.player?.insertItem(playerItem, afterItem: self.player?.items().last)
      }
    }
    queue.addOperation(loadPlayerItemOperation)
  }
}