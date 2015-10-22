//
//  UIViewController+Authentication.swift
//  Snowball
//
//  Created by James Martinez on 10/22/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import UIKit

extension UIViewController {
  func authenticateUser(ifAuthenticated: () -> Void) {
    if User.currentUser == nil {
      // TODO: Display Authentication
      print("DISPLAY AUTH")
    } else {
      ifAuthenticated()
    }
  }
}