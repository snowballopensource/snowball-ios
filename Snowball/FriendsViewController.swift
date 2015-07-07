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

  private let topView = SnowballTopView(leftButtonType: SnowballTopViewButtonType.Camera, rightButtonType: SnowballTopViewButtonType.AddFriends, title: NSLocalizedString("Friends", comment: ""))

  private let currentUserAvatarImageView: UserAvatarImageView = {
    let imageView = UserAvatarImageView()
    if let user = User.currentUser {
      imageView.configureForUser(user)
    }
    return imageView
  }()

  private let currentUserUsernameLabel: UILabel = {
    let label = UILabel()
    label.textColor = User.currentUser?.color as? UIColor
    label.font = UIFont(name: UIFont.SnowballFont.regular, size: 26)
    label.text = User.currentUser?.username
    return label
  }()

  private let currentUserProfileButton = UIButton()

  private let settingsButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(named: "settings"), forState: UIControlState.Normal)
    return button
  }()

  private enum FollowersFollowingSegmentedControlIndex: Int {
    case Following
    case Followers
  }

  private let followersFollowingSegmentedControl: UISegmentedControl = {
    let segmentedControl = UISegmentedControl()
    let segmentedControlFont = UIFont(name: UIFont.SnowballFont.bold, size: 17)!
    segmentedControl.setTitleTextAttributes([NSFontAttributeName: segmentedControlFont], forState: UIControlState.Normal)
    segmentedControl.insertSegmentWithTitle(NSLocalizedString("Following", comment: ""), atIndex: FollowersFollowingSegmentedControlIndex.Following.rawValue, animated: false)
    segmentedControl.insertSegmentWithTitle(NSLocalizedString("Followers", comment: ""), atIndex: FollowersFollowingSegmentedControlIndex.Followers.rawValue, animated: false)
    segmentedControl.selectedSegmentIndex = 0
    segmentedControl.tintColor = UIColor.blackColor()
    return segmentedControl
  }()

  private let tableView: UITableView = {
    let tableView = UITableView()
    tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    tableView.rowHeight = UserTableViewCell.height
    tableView.registerClass(UserTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UserTableViewCell))
    return tableView
  }()

  private var users: [User] = []

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

    currentUserProfileButton.addTarget(self, action: "currentUserProfileButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    view.addSubview(currentUserProfileButton)
    layout(currentUserProfileButton, currentUserAvatarImageView) { (currentUserProfileButton, currentUserAvatarImageView) in
      currentUserProfileButton.left == currentUserProfileButton.superview!.left
      currentUserProfileButton.top == currentUserAvatarImageView.top
      currentUserProfileButton.right == currentUserProfileButton.superview!.right
      currentUserProfileButton.bottom == currentUserAvatarImageView.bottom
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

    tableView.addRefreshControl(self, action: "refresh")
    tableView.dataSource = self
    tableView.delegate = self
    view.addSubview(tableView)
    layout(tableView, followersFollowingSegmentedControl) { (tableView, followersFollowingSegmentedControl) in
      tableView.left == tableView.superview!.left
      tableView.top == followersFollowingSegmentedControl.bottom + 15
      tableView.right == tableView.superview!.right
      tableView.bottom == tableView.superview!.bottom
    }
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    refresh()
  }

  // MARK: - Private

  @objc private func currentUserProfileButtonTapped() {
    if let user = User.currentUser {
      navigationController?.pushViewController(ProfileViewController(user: user), animated: true)
    }
  }

  @objc private func settingsButtonTapped() {
    navigationController?.pushViewController(EditProfileViewController(), animated: true)
  }

  @objc private func followersFollowingSegmentedControlTapped() {
    users = []
    tableView.reloadData()
    refresh()
  }

  @objc private func refresh() {
    tableView.refreshControl.beginRefreshing()
    tableView.offsetContentForRefreshControl()

    switch(followersFollowingSegmentedControl.selectedSegmentIndex) {
    case FollowersFollowingSegmentedControlIndex.Following.rawValue:
      API.request(Router.GetCurrentUserFollowing).responseJSON { (request, response, JSON, error) in
        self.tableView.refreshControl.endRefreshing()
        error?.print("api get current user following/followers")
        if let JSON: AnyObject = JSON {
          self.users = User.objectsFromJSON(JSON) as! [User]
          self.tableView.reloadData()
        }
      }
    case FollowersFollowingSegmentedControlIndex.Followers.rawValue:
      API.request(Router.GetCurrentUserFollowers).responseJSON { (request, response, JSON, error) in
        self.tableView.refreshControl.endRefreshing()
        error?.print("api get current user following/followers")
        if let JSON: AnyObject = JSON {
          self.users = User.objectsFromJSON(JSON) as! [User]
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
    switchToNavigationController(MainNavigationController())
  }

  func snowballTopViewRightButtonTapped() {
    navigationController?.pushViewController(FindFriendsViewController(), animated: true)
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
      forIndexPath: indexPath) as! UITableViewCell
    configureCell(cell, atIndexPath: indexPath)
    return cell
  }

  // MARK: - Private

  private func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    let cell = cell as! UserTableViewCell
    cell.selectionStyle = UITableViewCellSelectionStyle.None
    cell.delegate = self
    let user = users[indexPath.row]
    cell.configureForObject(user)
  }
}

// MARK: -

extension FriendsViewController: UITableViewDelegate {

  // MARK: - UITableViewDelegate

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let user = users[indexPath.row]
    navigationController?.pushViewController(ProfileViewController(user: user), animated: true)
  }
}

// MARK: - 

extension FriendsViewController: UserTableViewCellDelegate {

  // MARK: - UserTableViewCellDelegate

  func followUserButtonTappedInCell(cell: UserTableViewCell) {
    let indexPath = tableView.indexPathForCell(cell)!
    let user = users[indexPath.row]
    user.toggleFollowing()
    cell.configureForObject(user)
  }
}