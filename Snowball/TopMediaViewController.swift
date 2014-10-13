//
//  TopMediaViewController.swift
//  Snowball
//
//  Created by James Martinez on 9/24/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import AVFoundation
import UIKit

class TopMediaViewController: UIViewController, PlayerDelegate {
  private let cameraView = CameraView()
  private let captureSessionController = CaptureSessionController()
  private let playerView = PlayerView()
  typealias PlayerCompletionHandler = () -> ()
  private var playerCompletionHandler: PlayerCompletionHandler?

  func playReel(reel: Reel, completionHandler: PlayerCompletionHandler? = nil) {
    let player = Player(reel: reel)
    player.delegate = self
    playerView.player = player
    playerCompletionHandler = completionHandler
    player.play()
  }

  // MARK: -

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()
    cameraView.session = captureSessionController.captureSession
    captureSessionController.startSession()
    view.addFullViewSubview(cameraView)
    view.addFullViewSubview(playerView)
    playerView.hidden = false
  }

  // MARK: PlayerDelegate

  func playerItemDidPlayToEndTime(playerItem: AVPlayerItem) {
    let URLAsset = playerItem.asset as AVURLAsset
    let URL = URLAsset.URL
    Async.background {
      let clips = Clip.objectsWithPredicate(NSPredicate(format: "videoURL == %@", URL.absoluteString!))
      let clip = clips.firstObject() as Clip
      let reel = clip.reel
      RLMRealm.defaultRealm().beginWriteTransaction()
      reel?.lastWatchedClip = clip
      RLMRealm.defaultRealm().commitWriteTransaction()
    }
  }

  func playerDidFinishPlaying() {
    playerView.hidden = true
    if let completion = playerCompletionHandler { completion() }
  }
}