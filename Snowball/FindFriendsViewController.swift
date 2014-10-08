//
//  FindFriendsViewController.swift
//  Snowball
//
//  Created by James Martinez on 10/7/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Foundation

class FindFriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  let tableView = UITableView()
  var users = [User]()

  func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    cell.configureForObject(users[indexPath.row])
  }

  private func getUsersFromAddressBook() {
    AddressBookController.getAllPhoneNumbersWithCompletion { (granted, phoneNumbers) in
      if (granted) {
        if let phoneNumbers = phoneNumbers {
          API.request(APIRoute.FindUsersByPhoneNumbers(phoneNumbers: phoneNumbers)).responseObjects { (objects, error) in
            if error != nil { error?.display(); return }
            if let users = objects as? [User] {
              self.users = users
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
    tableView.registerClass(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.identifier)

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
    let cell = tableView.dequeueReusableCellWithIdentifier(UserTableViewCell.identifier, forIndexPath: indexPath) as UITableViewCell
    configureCell(cell, atIndexPath: indexPath)
    return cell
  }

  // MARK: UITableViewDelegate

  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UserTableViewCell.height()
  }
}