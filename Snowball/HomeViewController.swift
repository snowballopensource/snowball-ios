//
//  HomeViewController.swift
//  Snowball
//
//  Created by James Martinez on 3/2/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import UIKIt

class HomeViewController: UIViewController {

  // MARK: - Properties

  let clipsViewController = ClipsViewController()

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    addChildViewController(clipsViewController)
    view.addSubview(clipsViewController.view)
    clipsViewController.didMoveToParentViewController(self)
    clipsViewController.view.frame == view.bounds
  }
}
