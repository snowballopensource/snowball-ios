//
//  FindFriendsViewController.swift
//  Snowball
//
//  Created by James Martinez on 2/8/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

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
  var contactPhoneNumbers: [String] = ["+1 (415) 608-3256"] // TODO: get real contacts

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.whiteColor()

    view.addSubview(topView)
    topView.setupDefaultLayout()

    let margin: Float = 20

    tableView.dataSource = self
    view.addSubview(tableView)
    layout(tableView, topView) { (tableView, topView) in
      tableView.left == tableView.superview!.left
      tableView.top == topView.bottom
      tableView.right == tableView.superview!.right
      tableView.bottom == tableView.superview!.bottom
    }

    refresh()
  }

  // MARK: - Private

  private func refresh() {
    API.request(Router.FindUsersByPhoneNumbers(phoneNumbers: contactPhoneNumbers)).responseJSON { (request, response, JSON, error) in
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

  func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    let cell = cell as UserTableViewCell
    let user = users[indexPath.row]
    cell.configureForObject(user)
  }
}