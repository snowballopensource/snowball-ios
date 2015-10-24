//
//  RoundedCornerViewController.swift
//  Snowball
//
//  Created by James Martinez on 10/24/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class RoundedCornerViewController: UIViewController {

  init(childViewController: UIViewController) {
    super.init(nibName: nil, bundle: nil)

    addChildViewController(childViewController)
    let childView = childViewController.view
    view.addSubview(childView)
    constrain(childView) { childView in
      childView.left == childView.superview!.left
      childView.top == childView.superview!.top
      childView.right == childView.superview!.right
      childView.bottom == childView.superview!.bottom
    }
    childViewController.didMoveToParentViewController(self)

    childView.layer.cornerRadius = 10
    childView.clipsToBounds = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}