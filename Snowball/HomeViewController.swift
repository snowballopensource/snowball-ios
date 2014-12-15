//
//  HomeViewController.swift
//  Snowball
//
//  Created by James Martinez on 12/3/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class HomeViewController: UIViewController, ClipsViewControllerDelegate {
  let playerViewController = PlayerViewController()
  let cameraViewController = UIViewController() // TODO: use real vc
  let clipsViewController = ClipsViewController()

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    addChildViewController(playerViewController) {
      layout(self.playerViewController.view) { (playerViewControllerView) in
        playerViewControllerView.left == playerViewControllerView.superview!.left
        playerViewControllerView.top == playerViewControllerView.superview!.top
        playerViewControllerView.right == playerViewControllerView.superview!.right
        playerViewControllerView.height == playerViewControllerView.superview!.width
      }
    }

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

  // MARK: - ClipsViewControllerDelegate

  func clipSelected(clip: Clip) {
    let predicate = NSPredicate(format: "createdAt >= %@", clip.createdAt)
    let clips = Clip.findAll(predicate: predicate, sortDescriptors: [NSSortDescriptor(key: "createdAt", ascending: true)]) as [Clip]
    let videoURLs = clips.map { clip -> NSURL in
      return NSURL(string: clip.videoURL)!
    }
    playerViewController.playURLs(videoURLs)
  }
}
