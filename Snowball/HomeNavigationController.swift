//
//  HomeNavigationController.swift
//  Snowball
//
//  Created by James Martinez on 1/28/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Foundation
import UIKit

class HomeNavigationController: UINavigationController {
  init() {
    super.init(rootViewController: HomeTimelineViewController())
    navigationBar.transparent = true
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override init(nibName: String?, bundle: NSBundle?) {
    super.init(nibName: nibName, bundle: bundle)
  }
}