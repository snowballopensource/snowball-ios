//
//  PlayerViewController.swift
//  Snowball
//
//  Created by James Martinez on 10/12/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import AVFoundation
import UIKit

class PlayerViewController: UIViewController, PlayerDelegate {
  typealias CompletionHandler = () -> ()
  private var completionHandler: CompletionHandler?

  func playReel(reel: Reel, completionHandler: CompletionHandler? = nil) {
    let player = Player(reel: reel)
    player.delegate = self
    let playerView = view as PlayerView
    playerView.player = player
    self.completionHandler = completionHandler
    player.play()
  }

  // MARK: -

  // MARK: UIViewController

  override func loadView() {
    super.loadView()
    view = PlayerView()
  }

  // MARK: PlayerDelegate

  func playerItemDidPlayToEndTime(playerItem: AVPlayerItem) {
    let URLAsset = playerItem.asset as AVURLAsset
    let URL = URLAsset.URL
    Async.background {
      let clips = Clip.objectsWithPredicate(NSPredicate(format: "videoURL == %@", URL.absoluteString!))
      let clip = clips.firstObject() as Clip
      let reel = clip.reel
      reel?.lastWatchedClip = clip
    }
  }

  func playerDidFinishPlaying() {
    if let completion = completionHandler { completion() }
  }
}