//
//  FindFriendsViewController.swift
//  Snowball
//
//  Created by James Martinez on 10/7/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Foundation

class FindFriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FollowableUserTableViewCellDelegate {
  let tableView = UITableView()
  var users = [User]()

  func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    cell.configureForObject(users[indexPath.row])
    let followableUserCell = cell as FollowableUserTableViewCell
    followableUserCell.delegate = self
  }

  private func getUsersFromAddressBook() {
    AddressBookController.getAllPhoneNumbersWithCompletion { (granted, phoneNumbers) in
      if (granted) {
        if let phoneNumbers = phoneNumbers {
          API.request(APIRoute.FindUsersByPhoneNumbers(phoneNumbers: phoneNumbers)).responseObjects { (objects, error) in
            if error != nil { error?.display(); return }
            if let users = objects as? [User] {
              self.users = users.filter() { $0.youFollow == false }
              self.tableView.reloadData()
            }
          }
        }
      } else {
        // TODO: show not granted error
      }
    }
  }

  // MARK: -

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(tableView)
    tableView.dataSource = self
    tableView.delegate = self
    tableView.registerClass(FollowableUserTableViewCell.self, forCellReuseIdentifier: FollowableUserTableViewCell.identifier)

    title = NSLocalizedString("Find Friends")

    if AddressBookController.authorized {
      getUsersFromAddressBook()
    } else {
      // TODO: user needs to allow us, so present button
      println("unauthorized")
    }
  }

  override func viewWillLayoutSubviews() {
    tableView.frame = view.bounds
  }

  // MARK: UITableViewDataSource

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return users.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(FollowableUserTableViewCell.identifier, forIndexPath: indexPath) as UITableViewCell
    configureCell(cell, atIndexPath: indexPath)
    return cell
  }

  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return NSLocalizedString("Contacts who aren't yet my friends")
  }

  // MARK: UITableViewDelegate

  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return FollowableUserTableViewCell.height()
  }

  // MARK: FollowableUserTableViewCell

  func followButtonTappedForCell(cell: FollowableUserTableViewCell) {
    if let indexPath = tableView.indexPathForCell(cell) {
      let user = users[indexPath.row]
      users.removeAtIndex(indexPath.row)
      tableView.reloadData()
      API.request(APIRoute.FollowUser(userID: user.id)).responseObject { (object, error) in
        if error != nil {
          error?.display()
          self.users.insert(user, atIndex: indexPath.row)
          self.tableView.reloadData()
          return
        }
      }
    }
  }
}