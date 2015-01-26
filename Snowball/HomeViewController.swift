//
//  HomeViewController.swift
//  Snowball
//
//  Created by James Martinez on 12/3/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import AVFoundation
import Cartography
import UIKit

class HomeViewController: UIViewController, PlayerViewControllerDelegate, CameraViewControllerDelegate, ClipsViewControllerDelegate {
  let playerViewController = PlayerViewController()
  let cameraViewController = CameraViewController()
  let clipsViewController = ClipsViewController()
  var previewedVideoURL: NSURL?
  var previewedVideoThumbnailURL: NSURL?

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    playerViewController.delegate = self
    addChildViewController(playerViewController) {
      layout(self.playerViewController.view) { (playerViewControllerView) in
        playerViewControllerView.left == playerViewControllerView.superview!.left
        playerViewControllerView.top == playerViewControllerView.superview!.top
        playerViewControllerView.right == playerViewControllerView.superview!.right
        playerViewControllerView.height == playerViewControllerView.superview!.width
      }
    }

    cameraViewController.delegate = self
    addChildViewController(cameraViewController) {
      self.cameraViewController.view.frame = self.playerViewController.view.frame
    }

    clipsViewController.delegate = self
    addChildViewController(clipsViewController) {
      layout(self.clipsViewController.view, self.playerViewController.view) { (clipsViewControllerView, playerViewControllerView) in
        clipsViewControllerView.left == clipsViewControllerView.superview!.left
        clipsViewControllerView.top == playerViewControllerView.bottom
        clipsViewControllerView.right == clipsViewControllerView.superview!.right
        clipsViewControllerView.bottom == clipsViewControllerView.superview!.bottom
      }
    }
  }

  // MARK: - Private

  func stopPlaybackAndShowCamera() {
    cameraViewController.view.hidden = false
    playerViewController.stopPlayback()
  }

  // MARK: - PlayerViewControllerDelegate

  func playerItemDidPlayToEndTime(playerItem: AVPlayerItem, nextPlayerItem: AVPlayerItem?, willLoopPlayerItem: Bool) {
    if !willLoopPlayerItem {
      let asset = playerItem.asset as CachedURLAsset
      if let clip = Clip.clipWithVideoURL(asset.originalURL) {
        clip.played = true
        clip.save()
      }
      if let nextPlayerItem = nextPlayerItem {
        let asset = nextPlayerItem.asset as CachedURLAsset
        clipsViewController.scrollToClipWithVideoURL(asset.originalURL)
      } else {
        cameraViewController.view.hidden = false
      }
    }
  }

  func userCancelledClipPreviewPlayback() {
    clipsViewController.hideAddClipButton()
    stopPlaybackAndShowCamera()
  }

  // MARK: - CameraViewControllerDelegate

  func videoRecordedToFileAtURL(videoURL: NSURL, thumbnailURL: NSURL, error: NSError?) {
    if error != nil { return }
    cameraViewController.view.hidden = true
    clipsViewController.showAddClipButton()
    previewedVideoURL = videoURL
    previewedVideoThumbnailURL = thumbnailURL
    playerViewController.playLocalURL(videoURL)
  }

  // MARK: - ClipsViewControllerDelegate

  func clipSelected(clip: Clip) {
    let clips = Clip.playableClips(since: clip.createdAt)
    let videoURLs = clips.map { clip -> NSURL in
      return NSURL(string: clip.videoURL)!
    }
    cameraViewController.view.hidden = true
    playerViewController.playURLs(videoURLs)
  }

  func addClipButtonTapped() {
    stopPlaybackAndShowCamera()
    clipsViewController.hideAddClipButton()
    dispatch_async(dispatch_get_main_queue()) {
      if let currentUser = User.currentUser {
        if let videoURL = self.previewedVideoURL {
          if let thumbnailURL = self.previewedVideoThumbnailURL {
            let clip = Clip.newEntity() as Clip
            clip.videoURL = videoURL.absoluteString!
            clip.thumbnailURL = thumbnailURL.absoluteString!
            clip.user = currentUser
            clip.createdAt = NSDate()
            clip.save()
            self.clipsViewController.scrollToClip(clip)
            API.uploadClip(clip) { (request, response, JSON, error) in
              if error != nil { displayAPIErrorToUser(JSON); return }
              if let clipJSON: AnyObject = JSON {
                dispatch_async(dispatch_get_main_queue()) {
                  clip.assign(clipJSON)
                }
              }
            }
          }
        }
      }
    }
  }
}
