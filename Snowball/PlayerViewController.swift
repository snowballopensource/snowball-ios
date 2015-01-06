//
//  PlayerViewController.swift
//  Snowball
//
//  Created by James Martinez on 12/12/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import AVFoundation
import UIKit

protocol PlayerViewControllerDelegate {
  func playerItemDidPlayToEndTime(playerItem: AVPlayerItem, nextPlayerItem: AVPlayerItem?)
}

class PlayerViewController: UIViewController {
  private let player = AVQueuePlayer()
  private let playerView = PlayerView()
  private var observingCurrentPlayerItem = false // Hack to check if observing current item for "playbackLikelyToKeepUp"
  var delegate: PlayerViewControllerDelegate?

  // MARK: - Initialization

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  // MARK: - NSKeyValueObserving

  override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
    if keyPath == "playbackLikelyToKeepUp" {
      if let playerItem = object as? AVPlayerItem {
        if playerItem.playbackLikelyToKeepUp {
          player.play()
        }
      }
    }
  }

  // MARK: - UIViewController

  override func loadView() {
    view = playerView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    playerView.player = player
    player.play()
  }

  // MARK: - PlayerViewController

  func playURLs(URLs: [NSURL]) {
    player.removeAllItems()
    prebufferAndQueueURLs(URLs)
  }

  func playURL(URL: NSURL) {
    player.removeAllItems()
    prebufferAndQueueURL(URL)
  }

  // MARK: - Private

  private func prebufferAndQueueURLs(URLs: [NSURL]) {
    if URLs.count > 0 {
      prebufferAndQueueURL(URLs.first!) {
        var nextURLs = URLs
        nextURLs.removeAtIndex(0)
        self.prebufferAndQueueURLs(nextURLs)
      }
    }
  }

  private func prebufferAndQueueURL(URL: NSURL, completionHandler: (() -> ())? = nil) {
    let asset = AVURLAsset(URL: URL, options: nil)
    let requestedKeys = ["tracks", "playable"]
    asset.loadValuesAsynchronouslyForKeys(requestedKeys) {
      dispatch_async(dispatch_get_main_queue()) {
        for key in requestedKeys {
          var error: NSError?
          let keyStatus = asset.statusOfValueForKey(key, error: &error)
          if keyStatus == AVKeyValueStatus.Failed {
            println("Error with AVAsset: \(error)")
            return
          }
        }
        if !asset.playable {
          println("Asset not playable.")
          return
        }
        let playerItem = AVPlayerItem(asset: asset)
        NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: playerItem, queue: nil) { (notification) in
          let playerItem = notification.object! as AVPlayerItem
          let playerItems = self.player.items() as [AVPlayerItem]
          var index = find(playerItems, playerItem) ?? 0
          var nextPlayerItem: AVPlayerItem?
          index++
          if index < playerItems.count {
            nextPlayerItem = playerItems[index]
          }
          self.delegate?.playerItemDidPlayToEndTime(playerItem, nextPlayerItem: nextPlayerItem)

          if self.observingCurrentPlayerItem {
            playerItem.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
            self.observingCurrentPlayerItem = false
          }
        }
        NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemPlaybackStalledNotification, object: playerItem, queue: nil) { (notification) in
          let playerItem = notification.object! as AVPlayerItem
          playerItem.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: nil, context: nil)
          self.observingCurrentPlayerItem = true
        }
        self.player.insertItem(playerItem, afterItem: self.player.items().last as AVPlayerItem?)
        if let completion = completionHandler { completion() }
      }
      return
    }
  }
}

class PlayerView: UIView {
  var player: AVPlayer {
    get {
      let playerLayer = layer as AVPlayerLayer
      return playerLayer.player
    }
    set {
      let playerLayer = layer as AVPlayerLayer
      playerLayer.player = newValue
    }
  }

  // MARK: UIView

  override class func layerClass() -> AnyClass {
    return AVPlayerLayer.self
  }
}
