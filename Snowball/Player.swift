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

  private func prebufferAndQueueVideoURLs(videoURLs: [NSURL]) {
    if videoURLs.count > 0 {
      prebufferAndQueueVideoURL(videoURLs.first!) {
        var videoURLs = videoURLs
        videoURLs.removeAtIndex(0)
        self.prebufferAndQueueVideoURLs(videoURLs)
      }
    }
  }

  private func prebufferAndQueueVideoURL(videoURL: NSURL, completionHandler: (() -> ())? = nil) {
    AVURLAsset.createAssetFromURL(videoURL){ (asset, error) in
      if let asset = asset {
        self.prepareToPlayAsset(asset)
        if let completion = completionHandler { completion() }
      }
    }
  }

  private func prepareToPlayAsset(asset: AVURLAsset) {
    let requestedKeys = ["tracks" as NSString, "playable" as NSString] as [AnyObject]
    asset.loadValuesAsynchronouslyForKeys(requestedKeys) {
      Async.main {
        for key in requestedKeys {
          if let key = key as? String {
            var error: NSError?
            let keyStatus = asset.statusOfValueForKey(key, error: &error)
            if keyStatus == AVKeyValueStatus.Failed {
              println("Error with AVAsset: \(error)")
              return
            }
          }
        }
        if !asset.playable {
          println("Asset not playable.")
          return
        }
        let playerItem = AVPlayerItem(asset: asset)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidPlayToEndTime:", name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemPlaybackStalled:", name: AVPlayerItemPlaybackStalledNotification, object: playerItem)
        self.insertItem(playerItem, afterItem: self.items().last as AVPlayerItem?)
      }
      return
    }
  }

  // MARK: -

  // MARK: AVQueuePlayer

  init(reel: Reel) {
    super.init()
    actionAtItemEnd = AVPlayerActionAtItemEnd.Advance
    var videoURLs = [NSURL]()
    for clip in reel.playableClips() {
      let clip = clip as Clip
      videoURLs.append(NSURL(string: clip.videoURL))
    }
    prebufferAndQueueVideoURLs(videoURLs)
  }

  init(videoURL: NSURL) {
    super.init()
    actionAtItemEnd = AVPlayerActionAtItemEnd.None
    prebufferAndQueueVideoURL(videoURL)
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

}