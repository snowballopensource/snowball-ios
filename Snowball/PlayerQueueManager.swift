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
  var delegate: PlayerQueueManagerDelegate?
  private let queue: NSOperationQueue = {
    let queue = NSOperationQueue()
    queue.qualityOfService = .UserInitiated
    queue.maxConcurrentOperationCount = 1
    return queue
  }()
  private let desiredMaximumClipCount = 3
  private var uncancelledOperations: [NSOperation] {
    return queue.operations.filter({ !$0.cancelled })
  }

  // MARK: Internal

  func ensurePlayerQueueToppedOff() {
    let lastPlayerClip = (player?.items().last as? ClipPlayerItem)?.clip
    let lastLoadingClip = ((uncancelledOperations.last as? LoadPlayerItemOperation)?.playerItem as? ClipPlayerItem)?.clip
    guard let lastQueuedClip = lastLoadingClip != nil ? lastLoadingClip : lastPlayerClip else { return }
    fillPlayerQueueWithClips(clipsAfterClip(lastQueuedClip), ignoringPlayerItemsCount: false, readyToPlayFirstClip: nil)
  }

  func preparePlayerQueueToPlayClip(clip: Clip, readyToPlayFirstClip: (() -> Void)?) {
    delegate?.queueManager(self, willPreparePlayerQueueToPlayClip: clip)
    fillPlayerQueueWithClips(clipsIncludingAndAfterClip(clip), ignoringPlayerItemsCount: false, readyToPlayFirstClip: readyToPlayFirstClip)
  }

  func preparePlayerQueueToSkipToClip(clip: Clip, readyToPlayFirstClip: (() -> Void)?) {
    fillPlayerQueueWithClips(clipsIncludingAndAfterClip(clip), ignoringPlayerItemsCount: true, readyToPlayFirstClip: readyToPlayFirstClip)
  }

  func cancelAllOperations() {
    queue.cancelAllOperations()
  }

  // MARK: Private

  private func fillPlayerQueueWithClips(clips: Results<ActiveModel>, ignoringPlayerItemsCount: Bool, readyToPlayFirstClip: (() -> Void)?) {
    let playerItemsCount = ignoringPlayerItemsCount ? 0 : (player?.items().count ?? 0)
    let clipsEnqueuedCount = playerItemsCount + uncancelledOperations.count
    let totalClipsLeftCount = clips.count
    let maxCountOfClipsToAdd = desiredMaximumClipCount - clipsEnqueuedCount
    let countOfClipsToAdd = (totalClipsLeftCount >= maxCountOfClipsToAdd) ? maxCountOfClipsToAdd : totalClipsLeftCount
    if countOfClipsToAdd <= 0 { return }
    guard let clipsToEnqueue = Array(clips[0..<countOfClipsToAdd]) as? [Clip] else { return }
    enqueueClipsInPlayer(clipsToEnqueue, readyToPlayFirstClip: readyToPlayFirstClip)
  }

  private func enqueueClipsInPlayer(clips: [Clip], readyToPlayFirstClip: (() -> Void)?) {
    guard let clip = clips.first else { return }
    enqueueClipInPlayer(clip) {
      readyToPlayFirstClip?()
    }
    var nextClips = clips
    nextClips.removeFirst()
    enqueueClipsInPlayer(nextClips, readyToPlayFirstClip: nil)
  }

  private func enqueueClipInPlayer(clip: Clip, completion: () -> Void) {
    guard let playerItem = ClipPlayerItem(clip: clip) else { return }
    let loadPlayerItemOperation = LoadPlayerItemOperation(playerItem: playerItem)
    loadPlayerItemOperation.completionBlock = {
      if !loadPlayerItemOperation.cancelled {
        dispatch_async(dispatch_get_main_queue()) {
          self.player?.insertItem(playerItem, afterItem: self.player?.items().last)
          completion()
        }
      }
    }
    queue.addOperation(loadPlayerItemOperation)
  }

  private func clipsIncludingAndAfterClip(clip: Clip) -> Results<ActiveModel> {
    guard let clipCreatedAt = clip.createdAt else { return Clip.findAll() }
    return Clip.findAll().filter("createdAt >= %@", clipCreatedAt).sorted("createdAt", ascending: true)
  }

  private func clipsAfterClip(clip: Clip) -> Results<ActiveModel> {
    guard let clipCreatedAt = clip.createdAt else { return Clip.findAll() }
    return Clip.findAll().filter("createdAt > %@", clipCreatedAt).sorted("createdAt", ascending: true)
  }
}

// MARK: - PlayerQueueManagerDelegate
protocol PlayerQueueManagerDelegate {
  func queueManager(queueManager: PlayerQueueManager, willPreparePlayerQueueToPlayClip clip: Clip)
}