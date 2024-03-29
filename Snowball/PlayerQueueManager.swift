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

  private let timeline: Timeline
  weak var player: AVQueuePlayer?
  private let queue: OperationQueue = {
    let queue = OperationQueue()
    queue.qualityOfService = .userInitiated
    queue.maxConcurrentOperationCount = 1
    return queue
  }()
  private let desiredMaximumClipCount = 3
  private var uncancelledOperations: [Operation] {
    return queue.operations.filter({ !$0.isCancelled })
  }
  var isLoadingAdditionalClips: Bool {
    return (uncancelledOperations.count != 0)
  }
  var nextBufferingClip: Clip? {
    if let operation = uncancelledOperations.first as? LoadPlayerItemOperation {
      let playerItem = operation.playerItem as? ClipPlayerItem
      return playerItem?.clip
    }
    return nil
  }

  // MARK: Initializers

  init(timeline: Timeline) {
    self.timeline = timeline
  }

  // MARK: Internal

  func ensurePlayerQueueToppedOff() {
    let lastPlayerClip = (player?.items().last as? ClipPlayerItem)?.clip
    let lastLoadingClip = ((uncancelledOperations.last as? LoadPlayerItemOperation)?.playerItem as? ClipPlayerItem)?.clip
    guard let lastQueuedClip = lastLoadingClip != nil ? lastLoadingClip : lastPlayerClip else { return }
    fillPlayerQueueWithClips(timeline.clipsAfterClip(lastQueuedClip), ignoringPlayerItemsCount: false, readyToPlayFirstClip: nil)
  }

  func preparePlayerQueueToBeginPlaybackWithClip(_ clip: Clip) {
    fillPlayerQueueWithClips(timeline.clipsIncludingAndAfterClip(clip), ignoringPlayerItemsCount: false, readyToPlayFirstClip: nil)
  }

  func preparePlayerQueueToSkipToClip(_ clip: Clip, readyToPlayFirstClip: (() -> Void)?) {
    fillPlayerQueueWithClips(timeline.clipsIncludingAndAfterClip(clip), ignoringPlayerItemsCount: true, readyToPlayFirstClip: readyToPlayFirstClip)
  }

  func cancelAllOperations() {
    queue.cancelAllOperations()
  }

  // MARK: Private

  private func fillPlayerQueueWithClips(_ clips: [Clip], ignoringPlayerItemsCount: Bool, readyToPlayFirstClip: (() -> Void)?) {
    let playerItemsCount = ignoringPlayerItemsCount ? 0 : (player?.items().count ?? 0)
    let clipsEnqueuedCount = playerItemsCount + uncancelledOperations.count
    let totalClipsLeftCount = clips.count
    let maxCountOfClipsToAdd = desiredMaximumClipCount - clipsEnqueuedCount
    let countOfClipsToAdd = (totalClipsLeftCount >= maxCountOfClipsToAdd) ? maxCountOfClipsToAdd : totalClipsLeftCount
    if countOfClipsToAdd <= 0 { return }
    let clipsToEnqueue = Array(clips[clips.startIndex..<(clips.startIndex + countOfClipsToAdd)]) as [Clip]
    enqueueClipsInPlayer(clipsToEnqueue, readyToPlayFirstClip: readyToPlayFirstClip)
  }

  private func enqueueClipsInPlayer(_ clips: [Clip], readyToPlayFirstClip: (() -> Void)?) {
    guard let clip = clips.first else { return }
    enqueueClipInPlayer(clip) {
      readyToPlayFirstClip?()
    }
    var nextClips = clips
    nextClips.removeFirst()
    enqueueClipsInPlayer(nextClips, readyToPlayFirstClip: nil)
  }

  private func enqueueClipInPlayer(_ clip: Clip, completion: @escaping () -> Void) {
    guard let playerItem = ClipPlayerItem(clip: clip) else { return }
    let loadPlayerItemOperation = LoadPlayerItemOperation(playerItem: playerItem)
    weak var safeOperation = loadPlayerItemOperation
    loadPlayerItemOperation.completionBlock = {
      guard let operation = safeOperation else { return }
      if !operation.isCancelled {
        DispatchQueue.main.async {
          self.player?.insert(playerItem, after: self.player?.items().last)
          completion()
        }
      }
    }
    queue.addOperation(loadPlayerItemOperation)
  }
}
