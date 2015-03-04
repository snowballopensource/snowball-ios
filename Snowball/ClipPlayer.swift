//
//  ClipPlayer.swift
//  Snowball
//
//  Created by James Martinez on 3/2/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import AVFoundation

class ClipPlayer: AVPlayer {

  // MARK: - Properties

  var delegate: ClipPlayerDelegate?

  var playing: Bool {
    if rate > 0 && error == nil {
      return true
    }
    return false
  }

  var clip: Clip? {
    let playerItem = currentItem as? ClipPlayerItem
    if let playerItem = playerItem {
      return playerItem.clip
    }
    return nil
  }

  // MARK: - Internal

  func playClip(clip: Clip) {
    play()
    if currentItem == nil {
      delegate?.playerWillBeginPlayback()
    }
    Analytics.track("Watch Clip")
    delegate?.playerWillPlayClip(clip)
    if let videoURL = clip.videoURL {
      CachedURLAsset.createAssetFromRemoteURL(videoURL) { (asset, error) in
        error?.print("creating cached asset")
        if let asset = asset {
          let playerItem = ClipPlayerItem(clip: clip, asset: asset)
          self.registerPlayerItemForNotifications(playerItem)
          self.replaceCurrentItemWithPlayerItem(playerItem)
        }
      }
    }
  }

  func stop() {
    pause()
    replaceCurrentItemWithPlayerItem(nil)
    delegate?.playerDidEndPlayback()
  }

  // MARK: - Private

  private func registerPlayerItemForNotifications(playerItem: ClipPlayerItem) {
    NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: playerItem, queue: nil) { (notification) in
      NSNotificationCenter.defaultCenter().removeObserver(self)
      if let clip = self.clip {
        let notificationPlayerItem = notification.object as ClipPlayerItem
        if notificationPlayerItem.clip.id == clip.id {
          self.delegate?.clipDidPlayToEndTime(notificationPlayerItem.clip)
        }
      }
    }
  }
}

// MARK: -

protocol ClipPlayerDelegate {
  func playerWillBeginPlayback()
  func playerDidEndPlayback()
  func playerWillPlayClip(clip: Clip)
  func clipDidPlayToEndTime(clip: Clip)
}

// MARK: -

// TODO: make this private
class ClipPlayerItem: AVPlayerItem {

  // MARK: - Properties

  var clip: Clip!

  // MARK: - Initializers

  convenience init(clip: Clip) {
    self.init(asset: AVURLAsset(URL: clip.videoURL!, options: nil), automaticallyLoadedAssetKeys: ["tracks", "playable"])
    self.clip = clip
  }

  convenience init(clip: Clip, asset: AVAsset) {
    self.init(asset: asset)
    self.clip = clip
  }
}

// MARK: -

import Alamofire

// TODO: make this private
class CachedURLAsset: AVURLAsset {
  var originalURL: NSURL

  override init!(URL: NSURL!, options: [NSObject : AnyObject]!) {
    assert(false, "Do not use this initialization method for CachedURLAsset")
    originalURL = NSURL()
    super.init(URL: URL, options: options)
  }

  init(URL: NSURL, originalURL: NSURL) {
    self.originalURL = originalURL
    super.init(URL: URL, options: nil)
  }

  typealias CompletionHandler = (CachedURLAsset?, NSError?) -> ()

  class func createAssetFromRemoteURL(URL: NSURL, completionHandler: CompletionHandler? = nil) {
    // Create cache file URL using remote URL as key
    var cacheURL = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0] as? NSURL
    let key = URL.absoluteString!.stringByReplacingOccurrencesOfString("/", withString: "").stringByReplacingOccurrencesOfString(":", withString: "")
    cacheURL = cacheURL!.URLByAppendingPathComponent(key)

    // Return asset immediately if it exists in the cache
    if NSFileManager.defaultManager().fileExistsAtPath(cacheURL!.path!) {
      if let completion = completionHandler {
        completion(CachedURLAsset(URL: cacheURL!, originalURL: URL), nil)
        return
      }
    }

    // Asset doesn't exist in cache, fetch it
    Alamofire.download(.GET, URL.absoluteString!) { (temporaryURL, response) in
      // Specify where to save download (to the cache URL created above)
      if let cacheURL = cacheURL {
        return cacheURL
      }
      cacheURL = temporaryURL
      return cacheURL!
      }.response { (_, response, _, error) in
        if let error = error {
          if let completion = completionHandler { completion(nil, error) }
        } else {
          if let completion = completionHandler { completion(CachedURLAsset(URL: cacheURL!, originalURL: URL), nil) }
        }
    }
  }
}
