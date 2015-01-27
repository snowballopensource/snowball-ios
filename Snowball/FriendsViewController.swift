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
  lazy var tableViewDataSource: FriendsDataSource = {
    return FriendsDataSource(tableView: self.tableView)
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(topView)
    topView.setupDefaultLayout()

    tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    tableView.dataSource = tableViewDataSource
    tableView.delegate = self
    tableView.registerHeaderFooterClass(SnowballTableViewHeaderFooterView)
    view.addSubview(tableView)
    layout(tableView, topView) { (tableView, topView) in
      tableView.left == tableView.superview!.left
      tableView.top == topView.bottom
      tableView.right == tableView.superview!.right
      tableView.bottom == tableView.superview!.bottom
    }
  }

  // MARK: - UITableViewDelegate

  // TODO: there is probably a better way to do these delegate methods akin to the way we're handling data source
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UserTableViewCell.height()
  }

  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = SnowballTableViewHeaderFooterView()
    if section == FriendsTableViewSection.Me.rawValue {
      headerView.titleLabel.text = NSLocalizedString("ME")
    } else {
      headerView.titleLabel.text = NSLocalizedString("MY FRIENDS")
    }
    return headerView
  }

  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return SnowballTableViewHeaderFooterView.height()
  }

  // MARK: - SnowballTopViewDelegate

  func snowballTopViewLeftButtonTapped() {
    AppDelegate.switchToNavigationController(MainNavigationController())
  }

  func snowballTopViewRightButtonTapped() {
    println("hi")
  }
}

// MARK: -

enum FriendsTableViewSection: Int {
  case Me
  case Friends
}

// MARK: -

class FriendsDataSource: FetchedResultsTableViewDataSource {

  init(tableView: UITableView) {
    let cellTypes = [UserTableViewCell.self, UserTableViewCell.self] as [UITableViewCell.Type]
    let currentUserID = User.currentUser!.id ?? ""
    super.init(tableView: tableView, entityName: User.entityName(), sortDescriptors: [NSSortDescriptor(key: "username", ascending: true)], predicate: NSPredicate(format: "id != %@", currentUserID), cellTypes: cellTypes)
  }

  // MARK: - TableViewDataSource

  override func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    let cell = cell as UserTableViewCell
    if indexPath.section == FriendsTableViewSection.Me.rawValue {
      if let user = User.currentUser {
        cell.configureForObject(user)
      }
    } else {
      super.configureCell(cell, atIndexPath: originalIndexPathFromMappedIndexPath(indexPath))
    }
  }

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case FriendsTableViewSection.Me.rawValue: return 1
    default: return super.tableView(tableView, numberOfRowsInSection: 0)
    }
  }

  // MARK: - Index Path Mapping

  func originalIndexPathFromMappedIndexPath(indexPath: NSIndexPath) -> NSIndexPath {
    return NSIndexPath(forRow: indexPath.row, inSection: 0)
  }
}