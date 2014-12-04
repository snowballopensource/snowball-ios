//
//  UIViewController+ChildViewController.swift
//  Snowball
//
//  Created by James Martinez on 12/3/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

extension UIViewController {
  func addChildViewController(childViewController: UIViewController, layout: () -> ()) {
    addChildViewController(childViewController)
    view.addSubview(childViewController.view)
    childViewController.didMoveToParentViewController(self)
    layout()
  }
}