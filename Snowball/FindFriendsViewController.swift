//
//  FindFriendsViewController.swift
//  Snowball
//
//  Created by James Martinez on 2/8/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import AddressBook
import Cartography
import UIKit

class FindFriendsViewController: UIViewController {

  // MARK: - Properties

  let topView = SnowballTopView(leftButtonType: SnowballTopViewButtonType.Back, rightButtonType: nil, title: "Find Friends")

  let tableView: UITableView = {
    let tableView = UITableView()
    tableView.allowsSelection = false
    tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    tableView.rowHeight = UserTableViewCell.height
    tableView.registerClass(UserTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UserTableViewCell))
    return tableView
    }()

  var users: [User] = []

  let addressBook: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.whiteColor()

    view.addSubview(topView)
    topView.setupDefaultLayout()

    tableView.addRefreshControl(self, action: "refresh")
    tableView.dataSource = self
    view.addSubview(tableView)
    layout(tableView, topView) { (tableView, topView) in
      tableView.left == tableView.superview!.left
      tableView.top == topView.bottom
      tableView.right == tableView.superview!.right
      tableView.bottom == tableView.superview!.bottom
    }
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    ABAddressBookRequestAccessWithCompletion(addressBook) { (granted, error) in
      if granted {
        self.tableView.offsetContentForRefreshControl()
        self.refresh()
      }
    }
  }

  // MARK: - Private

  @objc private func refresh() {
    tableView.refreshControl.beginRefreshing()
    var phoneNumbers = [String]()
    let contacts = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as NSArray
    for contact in contacts {
      let phoneNumberProperty: AnyObject = ABRecordCopyValue(contact, kABPersonPhoneProperty).takeRetainedValue()
      for var i = 0; i < ABMultiValueGetCount(phoneNumberProperty); i++ {
        let phoneNumber = ABMultiValueCopyValueAtIndex(phoneNumberProperty, i).takeRetainedValue() as String
        phoneNumbers.append(phoneNumber)
      }
    }

    API.request(Router.FindUsersByPhoneNumbers(phoneNumbers: phoneNumbers)).responseJSON { (request, response, JSON, error) in
      self.tableView.refreshControl.endRefreshing()
      error?.print("api find friends")
      if let JSON: AnyObject = JSON {
        self.users = User.objectsFromJSON(JSON) as [User]
        self.tableView.reloadData()
      }
    }
  }
}

// MARK: -

extension FindFriendsViewController: SnowballTopViewDelegate {

  // MARK: - SnowballTopViewDelegate

  func snowballTopViewLeftButtonTapped() {
    navigationController?.popViewControllerAnimated(true)
  }
}

// MARK: -

extension FindFriendsViewController: UITableViewDataSource {

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

  private func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    let cell = cell as UserTableViewCell
    cell.delegate = self
    let user = users[indexPath.row]
    cell.configureForObject(user)
  }
}

// MARK: -

extension FindFriendsViewController: UserTableViewCellDelegate {

  // MARK: - UserTableViewCellDelegate

  func followUserButtonTappedInCell(cell: UserTableViewCell) {
    let indexPath = tableView.indexPathForCell(cell)!
    let user = users[indexPath.row]
    user.toggleFollowing()
    cell.configureForObject(user)
  }
}