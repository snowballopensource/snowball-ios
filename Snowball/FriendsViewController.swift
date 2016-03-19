//
//  FriendsViewController.swift
//  Snowball
//
//  Created by James Martinez on 1/28/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Cartography
import Foundation
import UIKit

class FriendsViewController: UIViewController {

  // MARK: Properties

  let segmentedControl: SegmentedControl = {
    let titles = [NSLocalizedString("Following", comment: ""), NSLocalizedString("Followers", comment: "")]
    let segmentedControl = SegmentedControl(titles: titles)
    return segmentedControl
  }()
  let tableView: UITableView = {
    let tableView = UITableView()
    tableView.rowHeight = UserTableViewCell.defaultHeight
    tableView.separatorStyle = .None
    return tableView
  }()
  var users = [User]()

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    title = NSLocalizedString("Friends", comment: "")
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "top-camera-outline"), style: .Plain, target: self, action: "leftBarButtonItemPressed")
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "top-add-friends"), style: .Plain, target: self, action: "rightBarButtonItemPressed")

    view.addSubview(segmentedControl)
    constrain(segmentedControl) { segmentedControl in
      segmentedControl.top == segmentedControl.superview!.top + navigationBarOffset
      segmentedControl.left == segmentedControl.superview!.left + 17
      segmentedControl.right == segmentedControl.superview!.right - 17
      segmentedControl.height == 35
    }
    segmentedControl.addTarget(self, action: "segmentedControlValueChanged", forControlEvents: .ValueChanged)

    view.addSubview(tableView)
    constrain(tableView, segmentedControl) { tableView, segmentedControl in
      tableView.top == segmentedControl.bottom + 10
      tableView.left == tableView.superview!.left
      tableView.bottom == tableView.superview!.bottom
      tableView.right == tableView.superview!.right
    }
    tableView.dataSource = self
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    refresh()
  }

  // MARK: Private

  private func refresh() {
    self.users.removeAll()
    self.tableView.reloadData()

    let route: SnowballRoute
    if segmentedControl.selectedIndex == 0 {
      route = SnowballRoute.GetCurrentUserFollowing
    } else {
      route = SnowballRoute.GetCurrentUserFollowers
    }
    SnowballAPI.requestObjects(route) { (response: ObjectResponse<[User]>) in
      switch response {
      case .Success(let users):
        self.users = users
        self.tableView.reloadData()
      case .Failure(let error): print(error) // TODO: Handle error
      }
    }
  }

  // MARK: Actions

  @objc private func leftBarButtonItemPressed() {
    AppDelegate.sharedInstance.window?.transitionRootViewControllerToViewController(HomeNavigationController())
  }

  @objc private func rightBarButtonItemPressed() {
    navigationController?.pushViewController(FindFriendsViewController(), animated: true)
  }

  @objc private func segmentedControlValueChanged() {
    refresh()
  }
}

// MARK: - UITableViewDataSource
extension FriendsViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return users.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = UserTableViewCell()
    let user = users[indexPath.row]
    cell.configureForUser(user)
    cell.delegate = self
    return cell
  }
}

// MARK: - UserTableViewCellDelegate
extension FriendsViewController: UserTableViewCellDelegate {
  func userTableViewCellFollowButtonTapped(cell: UserTableViewCell) {
    guard let indexPath = tableView.indexPathForCell(cell) else { return }
    let user = users[indexPath.row]
    guard let userID = user.id else { return }

    let followingCurrently = user.following

    func setFollowing(following: Bool) {
      Database.performTransaction {
        user.following = following
        Database.save(user)
      }
      cell.followButton.setFollowing(following, animated: true)
    }

    setFollowing(!followingCurrently)

    let route: SnowballRoute
    if followingCurrently {
      route = SnowballRoute.UnfollowUser(userID: userID)
    } else {
      route = SnowballRoute.FollowUser(userID: userID)
    }

    SnowballAPI.request(route) { response in
      switch response {
      case .Success: break
      case .Failure(let error):
        print(error)
        setFollowing(followingCurrently)
      }
    }
  }
}