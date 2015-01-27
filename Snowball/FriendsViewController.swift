//
//  FriendsViewController.swift
//  Snowball
//
//  Created by James Martinez on 1/26/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class FriendsViewController: UIViewController, SnowballTopViewDelegate {
  let topView = SnowballTopView(leftButtonType: SnowballTopViewButtonType.Camera, rightButtonType: SnowballTopViewButtonType.AddFriends)
  let tableView = UITableView()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(topView)
    topView.setupDefaultLayout()

    view.addSubview(tableView)
    layout(tableView, topView) { (tableView, topView) in
      tableView.left == tableView.superview!.left
      tableView.top == topView.bottom
      tableView.right == tableView.superview!.right
      tableView.bottom == tableView.superview!.bottom
    }
  }

  // MARK: - SnowballTopViewDelegate

  func snowballTopViewLeftButtonTapped() {
    AppDelegate.switchToNavigationController(MainNavigationController())
  }

  func snowballTopViewRightButtonTapped() {
    println("hi")
  }
}