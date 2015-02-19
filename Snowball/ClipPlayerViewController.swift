//
//  ClipPlayerViewController.swift
//  Snowball
//
//  Created by James Martinez on 2/9/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import AVFoundation
import Cartography
import UIKit

class ClipPlayerViewController: UIViewController {

  // MARK: - Properties

  let player = AVQueuePlayer()
  let playerView = PlayerView()
  var delegate: ClipPlayerViewControllerDelegate?

  // MARK: - UIViewController

  override func loadView() {
    view = playerView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    playerView.player = player
    player.play()
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

  // MARK: - Internal

  func playClips(clips: [Clip]) {
    player.play()
    let clip = clips.first!
    CachedURLAsset.createAssetFromRemoteURL(clip.videoURL!) { (asset, error) in
      if let asset = asset {
        let playerItem = ClipPlayerItem(clip: clip, asset: asset)
        NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: playerItem, queue: nil) { (notification) in
          let playerItem = notification.object as ClipPlayerItem
          self.delegate?.playerItemDidPlayToEndTime(playerItem)
          NSNotificationCenter.defaultCenter().removeObserver(self)
        }
        self.player.insertItem(playerItem, afterItem: self.player.items().last as? AVPlayerItem)
      }
      var mutableClips = clips
      mutableClips.removeAtIndex(0)
      if mutableClips.count > 0 {
        self.playClips(mutableClips)
      }
    }
  }

  func playClip(clip: Clip) {
    playClips([clip])
  }

  func endPlayback() {
    player.pause()
    player.removeAllItems()
  }
}

// MARK: -

protocol ClipPlayerViewControllerDelegate: class {
  func playerItemDidPlayToEndTime(playerItem: ClipPlayerItem)
}

// MARK: -

class PlayerView: UIView {

  // MARK: - Properties

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

  // MARK: - UIView

  override class func layerClass() -> AnyClass {
    return AVPlayerLayer.self
  }
}