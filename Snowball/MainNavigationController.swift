//
//  MainNavigationController.swift
//  Snowball
//
//  Created by James Martinez on 9/27/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {
  override init() {
    super.init(rootViewController: ReelsGridViewController())
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override init(nibName: String?, bundle: NSBundle?) {
    super.init(nibName: nibName, bundle: bundle)
  }
}