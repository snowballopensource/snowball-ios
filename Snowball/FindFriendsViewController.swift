//
//  FindFriendsViewController.swift
//  Snowball
//
//  Created by James Martinez on 2/8/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import AddressBook
import Cartography
import MessageUI
import UIKit

class FindFriendsViewController: UIViewController {

  // MARK: - Properties

  private let topView = SnowballTopView(leftButtonType: SnowballTopViewButtonType.Back, rightButtonType: nil, title: "Find Friends")

  private let tableView: UITableView = {
    let tableView = UITableView()
    tableView.allowsSelection = false
    tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    tableView.rowHeight = UserTableViewCell.height
    tableView.registerClass(UserTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UserTableViewCell))
    return tableView
    }()

  private let searchTextField: SnowballRoundedTextField = {
    let textField = SnowballRoundedTextField()
    textField.font = UIFont(name: UIFont.SnowballFont.regular, size: 19)
    textField.tintColor = UIColor.blackColor()
    textField.returnKeyType = UIReturnKeyType.Search
    textField.autocapitalizationType = UITextAutocapitalizationType.None
    textField.autocorrectionType = UITextAutocorrectionType.No
    textField.rightViewMode = UITextFieldViewMode.Always
    return textField
    }()

  private let tableViewLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: UIFont.SnowballFont.regular, size: 17)
    return label
    }()

  private var searching: Bool = false {
    didSet {
      users = []
      tableView.reloadData()
      searchTextField.text = nil

      if searching {
        searchTextField.setPlaceholder("", color: UIColor.blackColor())
        tableViewLabel.text = NSLocalizedString("Find by username")

        let cancelImage = UIImage(named: "search-cancel")!
        let cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: cancelImage.size.width + 20, height: cancelImage.size.height))
        cancelButton.setImage(cancelImage, forState: UIControlState.Normal)
        cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        cancelButton.addTarget(self, action: "searchCancelButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        searchTextField.rightView = cancelButton
      } else {
        searchTextField.endEditing(true)

        searchTextField.setPlaceholder(NSLocalizedString("Search by username"), color: UIColor.blackColor())
        tableViewLabel.text = NSLocalizedString("Friends from my address book")

        let searchImage = UIImage(named: "search")!
        let searchImageView = UIImageView(image: searchImage)
        searchImageView.contentMode = UIViewContentMode.Left
        searchImageView.frame = CGRect(x: 0, y: 0, width: searchImage.size.width + 20, height: searchImage.size.height)
        searchTextField.rightView = searchImageView
      }
    }
  }

  private var users: [User] = []

  private let addressBook: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()

  private let footerButton: SnowballFooterButton = {
    let button = SnowballFooterButton(rightImage: UIImage(named: "plane"))
    button.setTitle(NSLocalizedString("Invite a friend"), forState: UIControlState.Normal)
    return button
    }()

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.whiteColor()

    view.addSubview(topView)
    topView.setupDefaultLayout()

    searchTextField.delegate = self
    view.addSubview(searchTextField)
    let margin: CGFloat = 20
    layout(searchTextField, topView) { (searchTextField, topView) in
      searchTextField.left == searchTextField.superview!.left + margin
      searchTextField.top == topView.bottom
      searchTextField.right == searchTextField.superview!.right - margin
      searchTextField.height == 50
    }

    view.addSubview(tableViewLabel)
    layout(tableViewLabel, searchTextField) { (tableViewLabel, searchTextField) in
      tableViewLabel.left == tableViewLabel.superview!.left + margin
      tableViewLabel.top == searchTextField.bottom + 15
      tableViewLabel.right == tableViewLabel.superview!.right - margin
    }

    searching = false // Sets tableViewLabel text

    view.addSubview(footerButton)
    footerButton.setupDefaultLayout()
    footerButton.addTarget(self, action: "footerButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)

    tableView.addRefreshControl(self, action: "refresh")
    tableView.dataSource = self
    view.addSubview(tableView)
    layout(tableView, tableViewLabel, footerButton) { (tableView, tableViewLabel, footerButton) in
      tableView.left == tableView.superview!.left
      tableView.top == tableViewLabel.bottom + 5
      tableView.right == tableView.superview!.right
      tableView.bottom == footerButton.top
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

  private func searchForUserWithUsername(username: String) {
    tableView.refreshControl.beginRefreshing()
    API.request(Router.FindUsersByUsername(username: username)).responseJSON { (request, response, JSON, error) in
      self.tableView.refreshControl.endRefreshing()
      error?.print("api search for user by username")
      if let JSON: AnyObject = JSON {
        self.users = User.objectsFromJSON(JSON) as [User]
        self.tableView.reloadData()
      }
    }
  }

  @objc private func searchCancelButtonTapped() {
    cancelSearch()
  }

  private func cancelSearch() {
    searching = false
    refresh()
  }

  @objc private func footerButtonTapped() {
    let messageComposeViewController = MFMessageComposeViewController()
    messageComposeViewController.messageComposeDelegate = self
    var body = NSLocalizedString("Download the Snowball app (http://bit.ly/snblapp) and follow me.")
    if let username = User.currentUser?.username {
      body += NSLocalizedString(" My username is \(username).")
    }
    messageComposeViewController.body = body
    if MFMessageComposeViewController.canSendText() {
      presentViewController(messageComposeViewController, animated: true, completion: nil)
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

// MARK: -

extension FindFriendsViewController: UITextFieldDelegate {

  // MARK: - UITextFieldDelegate

  func textFieldDidBeginEditing(textField: UITextField) {
    searching = true
  }

  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if countElements(textField.text) > 2 {
      searchForUserWithUsername(textField.text)
    } else {
      cancelSearch()
    }
    return true
  }
}

// MARK: -

extension FindFriendsViewController: MFMessageComposeViewControllerDelegate {

  // MARK: - MFMessageComposeViewControllerDelegate

  func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
    controller.dismissViewControllerAnimated(true, completion: nil)
  }
}