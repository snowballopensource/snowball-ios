//
//  MoreNavigationController.swift
//  Snowball
//
//  Created by James Martinez on 1/26/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import UIKit

class MoreNavigationController: UINavigationController {

  // MARK: - Initializers

  init() {
    super.init(rootViewController: FriendsViewController())
    navigationBarHidden = true
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}