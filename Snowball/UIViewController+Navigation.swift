//
//  UIViewController+Navigation.swift
//  Snowball
//
//  Created by James Martinez on 2/1/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
  func isAppearingForFirstTime() -> Bool {
    return (isBeingPresented() || isMovingToParentViewController())
  }
}