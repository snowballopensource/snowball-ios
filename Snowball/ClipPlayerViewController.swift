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

  let player = AVPlayer()
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

  // MARK: - Internal

  func playClip(clip: NewClip) {
    let playerItem = ClipPlayerItem(URL: clip.videoURL!)
    playerItem.clip = clip
    NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: playerItem, queue: nil) { (notification) in
      self.delegate?.playerItemDidPlayToEndTime(playerItem)
      NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    player.replaceCurrentItemWithPlayerItem(playerItem)
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