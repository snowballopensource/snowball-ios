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

  let profileButton = UIButton()
  let userAvatarImageView = UserAvatarImageView()
  let usernameLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.SnowballFont.mediumFont.withSize(20)
    label.textAlignment = .center
    return label
  }()
  let editProfileButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(named: "top-settings"), for: UIControlState())
    return button
  }()
  let segmentedControl: SegmentedControl = {
    let titles = [NSLocalizedString("Following", comment: ""), NSLocalizedString("Followers", comment: "")]
    let segmentedControl = SegmentedControl(titles: titles)
    return segmentedControl
  }()
  let tableView: UITableView = {
    let tableView = UITableView()
    tableView.rowHeight = UserTableViewCell.defaultHeight
    tableView.separatorStyle = .none
    return tableView
  }()
  var users = [User]()

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "top-camera-outline"), style: .plain, target: self, action: #selector(FriendsViewController.leftBarButtonItemPressed))
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "top-search"), style: .plain, target: self, action: #selector(FriendsViewController.rightBarButtonItemPressed))

    view.addSubview(userAvatarImageView)
    constrain(userAvatarImageView) { userAvatarImageView in
      userAvatarImageView.top == userAvatarImageView.superview!.top + navigationBarOffset / 2
      userAvatarImageView.centerX == userAvatarImageView.superview!.centerX
      userAvatarImageView.height == 100
      userAvatarImageView.width == 100
    }

    view.addSubview(profileButton)
    constrain(profileButton, userAvatarImageView) { profileButton, userAvatarImageView in
      profileButton.top == userAvatarImageView.top
      profileButton.left == userAvatarImageView.left
      profileButton.right == userAvatarImageView.right
      profileButton.bottom == userAvatarImageView.bottom
    }
    profileButton.addTarget(self, action: #selector(FriendsViewController.profileButtonPressed), for: .touchUpInside)

    view.addSubview(usernameLabel)
    constrain(usernameLabel, userAvatarImageView) { usernameLabel, userAvatarImageView in
      usernameLabel.top == userAvatarImageView.bottom + 15
      usernameLabel.left == usernameLabel.superview!.left
      usernameLabel.right == usernameLabel.superview!.right
    }

    view.addSubview(editProfileButton)
    constrain(editProfileButton, usernameLabel) { editProfileButton, usernameLabel in
      editProfileButton.centerY == usernameLabel.centerY
      editProfileButton.right == editProfileButton.superview!.right - 5
      editProfileButton.width == 44
      editProfileButton.height == 44
    }
    editProfileButton.addTarget(self, action: #selector(FriendsViewController.editProfileButtonPressed), for: .touchUpInside)

    view.addSubview(segmentedControl)
    constrain(segmentedControl, usernameLabel) { segmentedControl, usernameLabel in
      segmentedControl.top == usernameLabel.bottom + 10
      segmentedControl.left == segmentedControl.superview!.left + 17
      segmentedControl.right == segmentedControl.superview!.right - 17
      segmentedControl.height == 35
    }
    segmentedControl.addTarget(self, action: #selector(FriendsViewController.segmentedControlValueChanged), for: .valueChanged)

    view.addSubview(tableView)
    constrain(tableView, segmentedControl) { tableView, segmentedControl in
      tableView.top == segmentedControl.bottom + 10
      tableView.left == tableView.superview!.left
      tableView.bottom == tableView.superview!.bottom
      tableView.right == tableView.superview!.right
    }
    tableView.dataSource = self
    tableView.delegate = self
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    reloadUserData()
    refresh()
  }

  // MARK: Private

  private func reloadUserData() {
    if let user = User.currentUser {
      // Handle coming back from EditProfile VC
      userAvatarImageView.setUser(user)
      usernameLabel.text = user.username
    }
  }

  private func refresh() {
    self.users.removeAll()
    self.tableView.reloadData()

    SnowballAPI.requestObject(SnowballRoute.getCurrentUser) { (response: ObjectResponse<User>) in
      switch response {
      case .success: self.reloadUserData()
      default: break
      }
    }

    let route: SnowballRoute
    if segmentedControl.selectedIndex == 0 {
      route = SnowballRoute.getCurrentUserFollowing
    } else {
      route = SnowballRoute.getCurrentUserFollowers
    }
    SnowballAPI.requestObjects(route) { (response: ObjectResponse<[User]>) in
      switch response {
      case .success(let users):
        self.users = users
        self.tableView.reloadData()
      case .failure(let error): print(error) // TODO: Handle error
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

  @objc private func profileButtonPressed() {
    guard let user = User.currentUser else { return }
    navigationController?.pushViewController(UserTimelineViewController(user: user), animated: true)
  }

  @objc private func editProfileButtonPressed() {
    navigationController?.pushViewController(EditProfileViewController(), animated: true)
  }
}

// MARK: - UITableViewDataSource
extension FriendsViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return users.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UserTableViewCell()
    let user = users[indexPath.row]
    cell.configureForUser(user)
    cell.delegate = self
    return cell
  }
}

// MARK: - UITableViewDelegate
extension FriendsViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let user = users[indexPath.row]
    navigationController?.pushViewController(UserTimelineViewController(user: user), animated: true)
  }
}

// MARK: - UserTableViewCellDelegate
extension FriendsViewController: UserTableViewCellDelegate {
  func userTableViewCellFollowButtonTapped(_ cell: UserTableViewCell) {
    guard let indexPath = tableView.indexPath(for: cell) else { return }
    let user = users[indexPath.row]
    guard let userID = user.id else { return }

    let followingCurrently = user.following

    func setFollowing(_ following: Bool) {
      let db = Database()
      db.performTransaction {
        user.following = following
        db.save(user)
      }
      cell.followButton.setFollowing(following, animated: true)
    }

    setFollowing(!followingCurrently)

    let route: SnowballRoute
    if followingCurrently {
      route = SnowballRoute.unfollowUser(userID: userID)
    } else {
      route = SnowballRoute.followUser(userID: userID)
    }

    SnowballAPI.request(route) { response in
      switch response {
      case .success: break
      case .failure(let error):
        print(error)
        setFollowing(followingCurrently)
      }
    }
  }
}
