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

  private func playerItems() -> [AVPlayerItem] {
    let playerView = view as PlayerView
    var items = playerView.player?.items()
    var playerItems = [AVPlayerItem]()
    for item in items! {
      let playerItem = item as AVPlayerItem
      playerItems.append(playerItem)
    }
    return playerItems
  }

  // MARK: UIViewController

  override func loadView() {
    view = PlayerView()
  }

  // MARK: ReelPlayerDelegate

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
