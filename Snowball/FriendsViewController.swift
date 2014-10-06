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
    var requestOneInProgress = true
    var requestTwoInProgress = true
    API.request(APIRoute.GetCurrentUser).responseCurrentUser { (error) in
      requestOneInProgress = false
      if !requestOneInProgress && !requestTwoInProgress {
        if error != nil { error?.display(); return }
        self.tableView.reloadData()
      }
    }
    API.request(APIRoute.GetCurrentUserFollowing).responsePersistable(User.self) { (error) in
      requestTwoInProgress = false
      if !requestOneInProgress && !requestTwoInProgress {
        if error != nil { error?.display(); return }
        self.tableView.reloadData()
      }
    }
  }

  // MARK: ManagedTableViewController

  override func cellType() -> UITableViewCell.Type {
    return UserTableViewCell.self
  }

  // MARK: UITableViewDataSource

  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }
}