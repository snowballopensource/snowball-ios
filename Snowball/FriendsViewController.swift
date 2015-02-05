//
//  FriendsViewController.swift
//  Snowball
//
//  Created by James Martinez on 2/4/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class FriendsViewController: UIViewController {

  // MARK: - Properties

  let topView = SnowballTopView(leftButtonType: SnowballTopViewButtonType.Camera, rightButtonType: SnowballTopViewButtonType.AddFriends, title: "Friends")

  let currentUserAvatarImageView: UserAvatarImageView = {
    let currentUserAvatarImageView = UserAvatarImageView()
    currentUserAvatarImageView.backgroundColor = User.currentUser?.color as? UIColor
    return currentUserAvatarImageView
  }()

  let currentUserUsernameLabel: UILabel = {
    let currentUserUsernameLabel = UILabel()
    currentUserUsernameLabel.textColor = User.currentUser?.color as? UIColor
    currentUserUsernameLabel.font = UIFont(name: UIFont.SnowballFont.regular, size: 26)
    currentUserUsernameLabel.text = User.currentUser?.username
    return currentUserUsernameLabel
  }()

  let settingsButton: UIButton = {
    let settingsButton = UIButton()
    settingsButton.setImage(UIImage(named: "settings"), forState: UIControlState.Normal)
    return settingsButton
  }()

  enum FollowersFollowingSegmentedControlIndex: Int {
    case Following
    case Followers
  }

  let followersFollowingSegmentedControl: UISegmentedControl = {
    let followersFollowingSegmentedControl = UISegmentedControl()
    let segmentedControlFont = UIFont(name: UIFont.SnowballFont.regular, size: 20)!
    followersFollowingSegmentedControl.setTitleTextAttributes([NSFontAttributeName: segmentedControlFont], forState: UIControlState.Normal)
    followersFollowingSegmentedControl.insertSegmentWithTitle(NSLocalizedString("Following"), atIndex: FollowersFollowingSegmentedControlIndex.Following.rawValue, animated: false)
    followersFollowingSegmentedControl.insertSegmentWithTitle(NSLocalizedString("Followers"), atIndex: FollowersFollowingSegmentedControlIndex.Followers.rawValue, animated: false)
    followersFollowingSegmentedControl.selectedSegmentIndex = 0
    followersFollowingSegmentedControl.tintColor = UIColor.blackColor()
    return followersFollowingSegmentedControl
  }()

  let tableView: UITableView = {
    let tableView = UITableView()
    tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    // TODO: change height to a class variable
    tableView.rowHeight = UserTableViewCell.height()
    // TODO: use .identifier instead of NSStringFromClass (use search to find all)
    tableView.registerClass(UserTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UserTableViewCell))
    tableView.registerClass(SnowballTableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: NSStringFromClass(SnowballTableViewHeaderFooterView))
    return tableView
  }()

  var users: [User] = []

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(topView)
    topView.setupDefaultLayout()

    let margin: Float = 20


    view.addSubview(currentUserAvatarImageView)
    layout(currentUserAvatarImageView, topView) { (currentUserAvatarImageView, topView) in
      currentUserAvatarImageView.left == currentUserAvatarImageView.superview!.left + margin
      currentUserAvatarImageView.top == topView.bottom + 20
      currentUserAvatarImageView.width == 40
      currentUserAvatarImageView.height == currentUserAvatarImageView.width
    }

    view.addSubview(currentUserUsernameLabel)
    layout(currentUserUsernameLabel, currentUserAvatarImageView) { (currentUserUsernameLabel, currentUserAvatarImageView) in
      currentUserUsernameLabel.left == currentUserAvatarImageView.right + 15
      currentUserUsernameLabel.centerY == currentUserAvatarImageView.centerY
    }

    settingsButton.addTarget(self, action: "settingsButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    view.addSubview(settingsButton)
    layout(settingsButton, currentUserAvatarImageView) { (settingsButton, currentUserAvatarImageView) in
      settingsButton.right == settingsButton.superview!.right - margin
      settingsButton.centerY == currentUserAvatarImageView.centerY
      settingsButton.width == 44
      settingsButton.height == settingsButton.width
    }

    followersFollowingSegmentedControl.addTarget(self, action: "followersFollowingSegmentedControlTapped", forControlEvents: UIControlEvents.ValueChanged)
    view.addSubview(followersFollowingSegmentedControl)
    layout(followersFollowingSegmentedControl, currentUserAvatarImageView) { (followersFollowingSegmentedControl, currentUserAvatarImageView) in
      followersFollowingSegmentedControl.top == currentUserAvatarImageView.bottom + 20
      followersFollowingSegmentedControl.left == followersFollowingSegmentedControl.superview!.left + margin
      followersFollowingSegmentedControl.right == followersFollowingSegmentedControl.superview!.right - margin
      followersFollowingSegmentedControl.height == 40
    }

    tableView.dataSource = self
    view.addSubview(tableView)
    layout(tableView, followersFollowingSegmentedControl) { (tableView, followersFollowingSegmentedControl) in
      tableView.left == tableView.superview!.left
      tableView.top == followersFollowingSegmentedControl.bottom + 15
      tableView.right == tableView.superview!.right
      tableView.bottom == tableView.superview!.bottom
    }

    refresh()
  }

  // MARK: - Actions

  func settingsButtonTapped() {
    navigationController?.pushViewController(EditProfileViewController(), animated: true)
  }

  func followersFollowingSegmentedControlTapped() {
    refresh()
  }

  // MARK: - Private

  private func refresh() {
    // TODO: remove duplication
    switch(followersFollowingSegmentedControl.selectedSegmentIndex) {
    case FollowersFollowingSegmentedControlIndex.Following.rawValue:
      API.request(Router.GetCurrentUserFollowing).responseJSON { (request, response, JSON, error) in
        error?.print("api get current user following/followers")
        if let JSON: AnyObject = JSON {
          self.users = User.objectsFromJSON(JSON) as [User]
          self.tableView.reloadData()
        }
      }
    case FollowersFollowingSegmentedControlIndex.Followers.rawValue:
      // TODO: get followers
      API.request(Router.GetCurrentUserFollowing).responseJSON { (request, response, JSON, error) in
        error?.print("api get current user following/followers")
        if let JSON: AnyObject = JSON {
          self.users = User.objectsFromJSON(JSON) as [User]
          self.tableView.reloadData()
        }
      }
    default: return
    }
  }
}

// MARK: -

extension FriendsViewController: SnowballTopViewDelegate {

  // MARK: - SnowballTopViewDelegate

  func snowballTopViewLeftButtonTapped() {
    AppDelegate.switchToNavigationController(MainNavigationController())
  }

  func snowballTopViewRightButtonTapped() {
    // TODO: go to add friends
  }
}

// MARK: -

extension FriendsViewController: UITableViewDataSource {

  // MARK: - UITableViewDataSource

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return users.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(UserTableViewCell),
      forIndexPath: indexPath) as UITableViewCell
    configureCell(cell, atIndexPath: indexPath)
    return cell
  }

  func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    let cell = cell as UserTableViewCell
    let user = users[indexPath.row]
    cell.configureForObject(user)
  }
}
