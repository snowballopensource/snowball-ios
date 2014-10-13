//
//  TopMediaViewController.swift
//  Snowball
//
//  Created by James Martinez on 9/24/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

class TopMediaViewController: UIViewController {
  private var cameraViewController: CameraViewController? {
    get {
      for childViewController in childViewControllers {
        if childViewController is CameraViewController {
          return childViewController as? CameraViewController
        }
      }
      return nil
    }
  }
  private var playerViewController: PlayerViewController? {
    get {
      for childViewController in childViewControllers {
        if childViewController is PlayerViewController {
          return childViewController as? PlayerViewController
        }
      }
      return nil
    }
  }

  func playReel(reel: Reel, completionHandler: PlayerViewController.CompletionHandler? = nil) {
    playerViewController?.playReel(reel, completionHandler: completionHandler)
  }

  // MARK: -

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()
    let cameraViewController = CameraViewController()
    addChildViewController(cameraViewController)
    view.addFullViewSubview(cameraViewController.view)
    let playerViewController = PlayerViewController()
    addChildViewController(playerViewController)
    view.addFullViewSubview(playerViewController.view)
  }
}