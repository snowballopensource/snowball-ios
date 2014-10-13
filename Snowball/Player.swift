//
//  Player.swift
//  Snowball
//
//  Created by James Martinez on 9/25/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import AVFoundation
import Foundation

protocol PlayerDelegate {
  func playerItemDidPlayToEndTime(playerItem: AVPlayerItem)
  func playerDidFinishPlaying()
}

class Player: AVQueuePlayer {
  var loop = false
  var delegate: PlayerDelegate?

  func playerItemDidPlayToEndTime(notification: NSNotification) {
    let playerItem = notification.object! as AVPlayerItem
    delegate?.playerItemDidPlayToEndTime(playerItem)
    if loop {
      playerItem.seekToTime(kCMTimeZero)
    } else {
      let lastPlayerItem = items().last as AVPlayerItem
      if lastPlayerItem == currentItem {
        delegate?.playerDidFinishPlaying()
      }
    }
  }

  func playerItemPlaybackStalled(notification: NSNotification) {
    let playerItem = notification.object! as AVPlayerItem
    playerItem.bk_addObserverForKeyPath("playbackLikelyToKeepUp") { (_) in
      if playerItem.playbackLikelyToKeepUp {
        self.play()
      }
    }
  }

  private func prebufferVideoURLs(videoURLs: [NSURL]) {
    if videoURLs.count > 0 {
      prebufferVideoURL(videoURLs.first!) {
        var videoURLs = videoURLs
        videoURLs.removeAtIndex(0)
        self.prebufferVideoURLs(videoURLs)
      }
    }
  }

  private func prebufferVideoURL(videoURL: NSURL, completionHandler: (() -> ())? = nil) {
    VideoCache.fetchVideoAtRemoteURL(videoURL) { (URL, error) in
      if let videoURL = URL {
        let playerItem = AVPlayerItem(URL: videoURL)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidPlayToEndTime:", name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemPlaybackStalled:", name: AVPlayerItemPlaybackStalledNotification, object: playerItem)
        self.insertItem(playerItem, afterItem: self.items().last as AVPlayerItem?)
        if let completion = completionHandler { completion() }
      }
    }
  }

  // MARK: -

  // MARK: AVQueuePlayer

  init(reel: Reel) {
    super.init()
    actionAtItemEnd = AVPlayerActionAtItemEnd.None
    var videoURLs = [NSURL]()
    for clip in reel.playableClips() {
      let clip = clip as Clip
      videoURLs.append(NSURL(string: clip.videoURL))
    }
    prebufferVideoURLs(videoURLs)
  }

  init(videoURL: NSURL) {
    super.init()
    actionAtItemEnd = AVPlayerActionAtItemEnd.None
    prebufferVideoURL(videoURL)
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

}