//
//  PlayerViewController.swift
//  Snowball
//
//  Created by James Martinez on 12/3/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import AVFoundation
import UIKit

class PlayerViewController: UIViewController, PlayerDelegate {
  func playClips(#since: NSDate?, clipCompletionHandler: ClipCompletionHandler? = nil, playerCompletionHandler: PlayerCompletionHandler? = nil) {
    self.clipCompletionHandler = clipCompletionHandler
    self.playerCompletionHandler = {
      self.view.bringSubviewToFront(self.cameraView)
      if let playerCompletionHandler = playerCompletionHandler {
        playerCompletionHandler()
      }
    }
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
    player.delegate = self
    playerView.player = player
    view.bringSubviewToFront(playerView)
    clipCompletionHandler = {
      player.seekToTime(kCMTimeZero)
    }
    player.play()
  }

  func endRecordingPreview() {
    view.bringSubviewToFront(cameraView)
    playerView.player?.pause()
    delegate?.capturedClipPreviewDidEnd()
  }

  // MARK: -

  // MARK: UIViewController

  override func loadView() {
    view = PlayerView()
  }

  // MARK: PlayerDelegate

  func playerItemDidPlayToEndTime(playerItem: AVPlayerItem) {
    // TODO: call delegate
  }

  func playerDidFinishPlaying() {
    // TODO: call delegate
  }
}