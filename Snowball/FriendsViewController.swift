//
//  FriendsViewController.swift
//  Snowball
//
//  Created by James Martinez on 1/26/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class FriendsViewController: UIViewController, SnowballTopViewDelegate, UITableViewDelegate {
  let topView = SnowballTopView(leftButtonType: SnowballTopViewButtonType.Camera, rightButtonType: SnowballTopViewButtonType.AddFriends)
  let tableView = UITableView()
  lazy var tableViewDataSource: FetchedResultsTableViewDataSource = {
    let cellTypes = [UserTableViewCell.self] as [UITableViewCell.Type]
    return FetchedResultsTableViewDataSource(tableView: self.tableView, entityName: User.entityName(), sortDescriptors: [NSSortDescriptor(key: "username", ascending: true)], cellTypes: cellTypes)
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(topView)
    topView.setupDefaultLayout()

    tableView.dataSource = tableViewDataSource
    tableView.delegate = self
    view.addSubview(tableView)
    layout(tableView, topView) { (tableView, topView) in
      tableView.left == tableView.superview!.left
      tableView.top == topView.bottom
      tableView.right == tableView.superview!.right
      tableView.bottom == tableView.superview!.bottom
    }
  }

  // MARK: - UITableViewDelegate

  // TODO: there is probably a better way to do this akin to the way we're handling data source
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UserTableViewCell.height()
  }

  // MARK: - SnowballTopViewDelegate

  func snowballTopViewLeftButtonTapped() {
    AppDelegate.switchToNavigationController(MainNavigationController())
  }

  func snowballTopViewRightButtonTapped() {
    println("hi")
  }
}