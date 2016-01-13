//
//  LoadPlayerItemOperation.swift
//  Snowball
//
//  Created by James Martinez on 1/7/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import AVFoundation
import Foundation

class LoadPlayerItemOperation: NSOperation {

  // MARK: Properties

  let playerItem: AVPlayerItem

  // MARK: Initializers

  init(playerItem: AVPlayerItem) {
    self.playerItem = playerItem
  }

  // MARK: NSOperation

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

  override func start() {
    if cancelled {
      finished = true
      return
    }
    executing = true

    playerItem.asset.loadValuesAsynchronouslyForKeys(["playable"]) {
      self.executing = false
      self.finished = true
    }
  }
}