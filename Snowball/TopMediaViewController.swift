//
//  TopMediaViewController.swift
//  Snowball
//
//  Created by James Martinez on 9/24/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import AVFoundation
import UIKit

protocol TopMediaViewControllerDelegate: class {
  func capturedClipPreviewWillStart()
  func capturedClipPreviewDidEnd()
}

class TopMediaViewController: UIViewController, PlayerDelegate, CaptureSessionControllerDelegate {
  var delegate: TopMediaViewControllerDelegate?
  private let cameraView = CameraView()
  private let recordingGestureRecognizer = UILongPressGestureRecognizer()
  private var captureSessionController: CaptureSessionController? // This cannot be initialized twice, as UIViewController subclasses sometimes do (see: http://stackoverflow.com/q/26084583/801858 ), so we initialize it in viewDidLoad
  private let playerView = PlayerView()
  typealias ClipCompletionHandler = () -> ()
  private var clipCompletionHandler: ClipCompletionHandler?
  typealias PlayerCompletionHandler = ClipCompletionHandler
  private var playerCompletionHandler: PlayerCompletionHandler?

  func playClips(#since: NSDate?, clipCompletionHandler: ClipCompletionHandler? = nil, playerCompletionHandler: PlayerCompletionHandler? = nil) {
    self.clipCompletionHandler = clipCompletionHandler
    self.playerCompletionHandler = playerCompletionHandler
    Async.userInitiated {
      var videoURLs = [NSURL]()
      var clips = Clip.playableClips
      if let since = since {
        clips = clips.objectsWhere("createdAt >= %@", since)
      }
      for object in clips {
        let clip = object as Clip
        videoURLs.append(NSURL(string: clip.videoURL)!)
      }
      let player = Player(remoteVideoURLs: videoURLs)
      player.delegate = self
      self.playerView.player = player
      Async.main {
        self.view.bringSubviewToFront(self.playerView)
        player.play()
      }
    }
  }

  func showRecordingPreview(URL: NSURL) {
    delegate?.capturedClipPreviewWillStart()
    let player = Player(localVideoURL: URL)
    playerView.player = player
    view.bringSubviewToFront(playerView)
    player.play()
  }

  func endRecordingPreview() {
    view.bringSubviewToFront(cameraView)
    playerView.player?.pause()
    delegate?.capturedClipPreviewDidEnd()
  }

  func toggleRecording() {
    switch (recordingGestureRecognizer.state) {
      case UIGestureRecognizerState.Began: captureSessionController?.beginRecording()
      case UIGestureRecognizerState.Ended: captureSessionController?.endRecording()
      default: return
    }
  }

  // MARK: -

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()
    captureSessionController = CaptureSessionController()
    cameraView.session = captureSessionController!.captureSession
    captureSessionController!.delegate = self
    captureSessionController!.startSession()
    playerView.backgroundColor = UIColor.blackColor()
    view.addFullViewSubview(playerView)
    cameraView.backgroundColor = UIColor.lightGrayColor()
    recordingGestureRecognizer.addTarget(self, action: "toggleRecording")
    recordingGestureRecognizer.minimumPressDuration = 0.2
    cameraView.addGestureRecognizer(recordingGestureRecognizer)
    view.addFullViewSubview(cameraView)
  }

  // MARK: PlayerDelegate

  func playerItemDidPlayToEndTime(playerItem: AVPlayerItem) {
    if let completion = clipCompletionHandler { completion () }
  }

  func playerDidFinishPlaying() {
    view.bringSubviewToFront(cameraView)
    if let completion = playerCompletionHandler { completion() }
  }

  // MARK: CaptureSessionControllerDelegate

  func movieRecordedToFileAtURL(fileURL: NSURL, error: NSError?) {
    if error != nil { error?.display(); return }
    showRecordingPreview(fileURL)
  }
}