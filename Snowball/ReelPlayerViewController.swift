//
//  ReelPlayerViewController.swift
//  Snowball
//
//  Created by James Martinez on 9/25/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import AVFoundation
import UIKit

class ReelPlayerViewController: UIViewController, ReelPlayerDelegate {
  typealias CompletionHandler = () -> ()
  private var completionHandler: CompletionHandler?

  func playReel(reel: Reel, completionHandler: CompletionHandler? = nil) {
    let player = ReelPlayer(reel: reel)
    player.delegate = self
    let playerView = view as PlayerView
    playerView.player = player
    self.completionHandler = completionHandler
    player.play()
  }

  // MARK: UIViewController

  override func loadView() {
    view = PlayerView()
  }

  // MARK: ReelPlayerDelegate

  func playerItemDidPlayToEndTime(playerItem: AVPlayerItem) {}

  func playerDidFinishPlaying() {
    if let completion = completionHandler { completion() }
  }
}
