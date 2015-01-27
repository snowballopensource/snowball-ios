//
//  FriendsViewController.swift
//  Snowball
//
//  Created by James Martinez on 1/26/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class FriendsViewController: UIViewController {
  let topView = SnowballTopView()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(topView)
    topView.setLayout()
  }
}