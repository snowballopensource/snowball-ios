//
//  LoadPlayerItemOperation.swift
//  Snowball
//
//  Created by James Martinez on 1/7/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import AVFoundation
import Foundation

class LoadPlayerItemOperation: Operation {

  // MARK: Properties

  let playerItem: AVPlayerItem

  // MARK: Initializers

  init(playerItem: AVPlayerItem) {
    self.playerItem = playerItem
  }

  // MARK: NSOperation

  override var isAsynchronous: Bool { return true }

  fileprivate var _executing = false
  override var isExecuting: Bool {
    get {
      return _executing
    }
    set {
      willChangeValue(forKey: "isExecuting")
      _executing = newValue
      didChangeValue(forKey: "isExecuting")
    }
  }

  fileprivate var _finished = false
  override var isFinished: Bool {
    get {
      return _finished
    }
    set {
      willChangeValue(forKey: "isFinished")
      _finished = newValue
      didChangeValue(forKey: "isFinished")
    }
  }

  override func start() {
    if isCancelled {
      isFinished = true
      return
    }
    isExecuting = true

    playerItem.asset.loadValuesAsynchronously(forKeys: ["playable"]) {
      self.isExecuting = false
      self.isFinished = true
    }
  }
}
