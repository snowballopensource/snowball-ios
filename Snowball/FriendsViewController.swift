//
//  FriendsViewController.swift
//  Snowball
//
//  Created by James Martinez on 9/28/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

class FriendsViewController: ManagedTableViewController, CurrentUserTableViewCellDelegate {

  func switchToMainNavigationController() {
    switchToNavigationController(MainNavigationController())
  }

  func pushFindFriendsViewController() {
    navigationController?.pushViewController(FindFriendsViewController(), animated: true)
  }

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    title = NSLocalizedString("My Friends")

    let leftBarButton = UIButton(frame: CGRectMake(0, 0, 44.0, 44.0))
    leftBarButton.setTitle(NSLocalizedString("Back"), forState: UIControlState.Normal)
    leftBarButton.addTarget(self, action: "switchToMainNavigationController", forControlEvents: UIControlEvents.TouchUpInside)
    leftBarButton.setTitleColorWithAutomaticHighlightColor()
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBarButton)
    let rightBarButton = UIButton(frame: CGRectMake(0, 0, 44.0, 44.0))
    rightBarButton.setTitle(NSLocalizedString("Find Friends"), forState: UIControlState.Normal)
    rightBarButton.addTarget(self, action: "pushFindFriendsViewController", forControlEvents: UIControlEvents.TouchUpInside)
    rightBarButton.setTitleColorWithAutomaticHighlightColor()
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)
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
    API.request(APIRoute.GetCurrentUser).responsePersistable(User.self) { (object, error) in
      requestOneInProgress = false
      if requestsError == nil { requestsError = error }
      if !requestOneInProgress && !requestTwoInProgress {
        if requestsError != nil { requestsError?.display(); return }
        self.tableView.reloadData()
      }
    }
    API.request(APIRoute.GetCurrentUserFollowing).responsePersistable(User.self) { (object, error) in
      requestTwoInProgress = false
      if requestsError == nil { requestsError = error }
      if !requestOneInProgress && !requestTwoInProgress {
        if requestsError != nil { requestsError?.display(); return }
        self.tableView.reloadData()
      }
    }
  }

  // MARK: ManagedTableViewController

  override func cellTypeInSection(section: Int) -> UITableViewCell.Type {
    switch section {
      case 0: return CurrentUserTableViewCell.self
      default: return UserTableViewCell.self
    }
  }

  override func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    super.configureCell(cell, atIndexPath: indexPath)
    if let currentUserCell = cell as? CurrentUserTableViewCell {
      currentUserCell.delegate = self
    }
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

  // MARK: UserTableViewCellDelegate

  func settingsButtonTapped() {
    navigationController?.pushViewController(EditProfileViewController(), animated: true)
  }
}