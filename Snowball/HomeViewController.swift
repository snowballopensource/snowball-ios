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

  // MARK: - PlayerViewControllerDelegate

  func playerItemDidPlayToEndTime(playerItem: AVPlayerItem, nextPlayerItem: AVPlayerItem?) {
    let asset = playerItem.asset as AVURLAsset
    if let clip = Clip.clipWithVideoURL(asset.URL) {
      clip.played = true
      clip.save()
    }
    if let nextPlayerItem = nextPlayerItem {
      let asset = nextPlayerItem.asset as AVURLAsset
      clipsViewController.scrollToClipWithVideoURL(asset.URL)
    } else {
      cameraViewController.view.hidden = false
    }
  }

  // MARK: - CameraViewControllerDelegate

  func movieRecordedToFileAtURL(fileURL: NSURL, error: NSError?) {
    if error != nil { return }
    cameraViewController.view.hidden = true
    playerViewController.playURL(fileURL)
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
}
