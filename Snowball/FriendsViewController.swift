//
//  FriendsViewController.swift
//  Snowball
//
//  Created by James Martinez on 1/28/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Foundation
import UIKit

class FriendsViewController: UIViewController {

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "top-camera-outline"), style: .Plain, target: self, action: "leftBarButtonItemPressed")
    navigationItem.leftBarButtonItem?.tintColor = UIColor.blackColor()
  }

  @objc private func leftBarButtonItemPressed() {
    AppDelegate.sharedInstance.window?.transitionRootViewControllerToViewController(HomeNavigationController())
  }
}