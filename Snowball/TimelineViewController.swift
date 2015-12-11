//
//  TimelineViewController.swift
//  Snowball
//
//  Created by James Martinez on 12/10/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class TimelineViewController: ViewController {

  // MARK: Properties

  let timelineView = TimelineView()

  // MARK: ViewController

  override func setupSubviews() {
    super.setupSubviews()

    view.addSubview(timelineView)
    constrain(timelineView) { timelineView in
      timelineView.top == timelineView.superview!.centerY
      timelineView.right == timelineView.superview!.right
      timelineView.bottom == timelineView.superview!.bottom
      timelineView.left == timelineView.superview!.left
    }
  }
}
