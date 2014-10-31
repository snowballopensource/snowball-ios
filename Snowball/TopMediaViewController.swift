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
  typealias ClipCompletionHandler = () -> ()
  private var clipCompletionHandler: ClipCompletionHandler?
  typealias PlayerCompletionHandler = ClipCompletionHandler
  private var playerCompletionHandler: PlayerCompletionHandler?

  func playClips(clipCompletionHandler: ClipCompletionHandler? = nil, playerCompletionHandler: PlayerCompletionHandler? = nil) {
    self.clipCompletionHandler = clipCompletionHandler
    self.playerCompletionHandler = playerCompletionHandler
    Async.userInitiated {
      var videoURLs = [NSURL]()
      for object in Clip.playableClips {
        let clip = object as Clip
        videoURLs.append(NSURL(string: clip.videoURL)!)
      }
      Async.main {
        let player = Player(videoURLs: videoURLs)
        player.delegate = self
        self.playerView.player = player
        self.view.bringSubviewToFront(self.playerView)
        player.play()
      }
    }
  }

  // MARK: -

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()
    cameraView.session = captureSessionController.captureSession
    captureSessionController.startSession()
    playerView.backgroundColor = UIColor.blueColor()
    view.addFullViewSubview(playerView)
    cameraView.backgroundColor = UIColor.lightGrayColor()
    view.addFullViewSubview(cameraView)
  }

  // MARK: PlayerDelegate

  func playerItemDidPlayToEndTime(playerItem: AVPlayerItem) {
    if let completion = clipCompletionHandler { completion () }
    // TODO: bring this back?
//    let URLAsset = playerItem.asset as AVURLAsset
//    let URL = URLAsset.URL
//    Async.background {
//      let clips = Clip.objectsWithPredicate(NSPredicate(format: "videoURL == %@", URL.absoluteString!))
//      let clip = clips.firstObject() as Clip
//      let reel = clip.reel
//      RLMRealm.defaultRealm().beginWriteTransaction()
//      reel?.lastWatchedClip = clip
//      RLMRealm.defaultRealm().commitWriteTransaction()
//    }
  }

  func playerDidFinishPlaying() {
    view.bringSubviewToFront(cameraView)
    if let completion = playerCompletionHandler { completion() }
  }
}