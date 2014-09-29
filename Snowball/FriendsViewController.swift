//
//  FriendsViewController.swift
//  Snowball
//
//  Created by James Martinez on 9/28/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

class FriendsViewController: ManagedTableViewController {

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.registerClass(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.identifier)
  }

  // MARK: ManagedViewController

  override func objectsInSection(section: Int) -> RLMArray {
    switch section {
      case 0: return User.currentUserManagedArray()
      default: return User.allObjects()
    }
  }

  override func reloadData() {
    API.getCurrentUserFollowing { (error) in
      if error != nil { error?.display(); return }
      self.tableView.reloadData()
    }
  }

  // MARK: ManagedTableViewController

  override func cellType() -> UITableViewCell.Type {
    return UserTableViewCell.self
  }

  override func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    let user = objectsInSection(indexPath.section).objectAtIndex(UInt(indexPath.row)) as User
    cell.textLabel!.text = user.name
  }

  // MARK: UITableViewDataSource

  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }
}