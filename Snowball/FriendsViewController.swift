//
//  FriendsViewController.swift
//  Snowball
//
//  Created by James Martinez on 9/28/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

class FriendsViewController: ManagedTableViewController {

  func switchToMainNavigationController() {
    switchToNavigationController(MainNavigationController())
  }

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    title = NSLocalizedString("My Friends")

    let leftBarButton = UIButton(frame: CGRectMake(0, 0, 44.0, 44.0))
    leftBarButton.setTitle(NSLocalizedString("Back"), forState: UIControlState.Normal)
    leftBarButton.addTarget(self, action: "switchToMainNavigationController", forControlEvents: UIControlEvents.TouchUpInside)
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBarButton)

    tableView.registerClass(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.identifier)
  }

  // MARK: ManagedViewController

  override func objectsInSection(section: Int) -> RLMArray {
    switch section {
      case 0: return User.currentUserManagedArray()
      default: return User.following()
    }
  }

  override func reloadData() {
    var requestOneInProgress = true
    var requestTwoInProgress = true
    var requestsError: NSError? = nil
    API.request(APIRoute.GetCurrentUser).responseCurrentUser { (error) in
      requestOneInProgress = false
      if requestsError == nil { requestsError = error }
      if !requestOneInProgress && !requestTwoInProgress {
        if requestsError != nil { requestsError?.display(); return }
        self.tableView.reloadData()
      }
    }
    API.request(APIRoute.GetCurrentUserFollowing).responsePersistable(User.self) { (error) in
      requestTwoInProgress = false
      if requestsError == nil { requestsError = error }
      if !requestOneInProgress && !requestTwoInProgress {
        if requestsError != nil { requestsError?.display(); return }
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

  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch(section) {
      case 0: return NSLocalizedString("Me")
      case 1: return NSLocalizedString("My Friends")
      default: return nil
    }
  }
}