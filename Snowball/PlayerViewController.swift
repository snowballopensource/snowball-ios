//
//  PlayerViewController.swift
//  Snowball
//
//  Created by James Martinez on 12/12/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import AVFoundation
import Cartography
import UIKit

protocol PlayerViewControllerDelegate: class {
  func playerItemDidPlayToEndTime(playerItem: AVPlayerItem, nextPlayerItem: AVPlayerItem?, willLoopPlayerItem: Bool)
  func userCancelledClipPreviewPlayback()
}

class PlayerViewController: UIViewController {
  private let player = AVQueuePlayer()
  private let playerView = PlayerView()
  private let cancelPreviewButton = UIButton()
  private var observingCurrentPlayerItem = false // Hack to check if observing current item for "playbackLikelyToKeepUp"
  private var playbackIsPreview = false
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

    cancelPreviewButton.setImage(UIImage(named: "x"), forState: UIControlState.Normal)
    cancelPreviewButton.addTarget(delegate, action: "userCancelledClipPreviewPlayback", forControlEvents: UIControlEvents.TouchUpInside)
    cancelPreviewButton.hidden = true
    view.addSubview(cancelPreviewButton)
    layout(cancelPreviewButton) { (cancelPreviewButton) in
      let margin: Float = 10
      let width: Float = 44
      cancelPreviewButton.centerX == cancelPreviewButton.superview!.centerX
      cancelPreviewButton.top == cancelPreviewButton.superview!.top + margin
      cancelPreviewButton.width == width
      cancelPreviewButton.height == width
    }
  }

  // MARK: - PlayerViewController

  func playURLs(URLs: [NSURL]) {
    player.removeAllItems()
    player.actionAtItemEnd = AVPlayerActionAtItemEnd.Advance
    playbackIsPreview = false
    cancelPreviewButton.hidden = !playbackIsPreview
    prebufferAndQueueURLs(URLs)
  }

  func playURL(URL: NSURL, loop: Bool = true) {
    player.removeAllItems()
    player.actionAtItemEnd = AVPlayerActionAtItemEnd.None
    playbackIsPreview = loop
    cancelPreviewButton.hidden = !playbackIsPreview
    prebufferAndQueueURL(URL)
  }

  func stopPlayback() {
    player.removeAllItems()
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
    CachedURLAsset.createAssetFromRemoteURL(URL){ (asset, error) in
      if let asset = asset {
        self.prepareToPlayAsset(asset, completionHandler: completionHandler)
      }
    }
  }

  private func prepareToPlayAsset(asset: AVAsset, completionHandler: (() -> ())? = nil) {
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
          if self.playbackIsPreview {
            playerItem.seekToTime(kCMTimeZero)
          } else {
            if self.observingCurrentPlayerItem {
              playerItem.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
              self.observingCurrentPlayerItem = false
            }
          }
          let playerItem = notification.object! as AVPlayerItem
          let playerItems = self.player.items() as [AVPlayerItem]
          var index = find(playerItems, playerItem) ?? 0
          var nextPlayerItem: AVPlayerItem?
          index++
          if index < playerItems.count {
            nextPlayerItem = playerItems[index]
          }
          self.delegate?.playerItemDidPlayToEndTime(playerItem, nextPlayerItem: nextPlayerItem, willLoopPlayerItem: self.playbackIsPreview)
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
