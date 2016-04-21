//
//  AuthenticationNavigationController.swift
//  Snowball
//
//  Created by James Martinez on 2/25/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Foundation
import UIKit

class AuthenticationNavigationController: UINavigationController {
  init() {
    super.init(rootViewController: AuthenticationViewController())
    navigationBar.transparent = true
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override init(nibName: String?, bundle: NSBundle?) {
    super.init(nibName: nibName, bundle: bundle)
  }
}