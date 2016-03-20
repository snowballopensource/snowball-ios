//
//  FindFriendsViewController.swift
//  Snowball
//
//  Created by James Martinez on 3/19/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import AddressBook
import Cartography
import Foundation
import UIKit

class FindFriendsViewController: UIViewController {

  // MARK: Properties

  let segmentedControl: SegmentedControl = {
    let titles = [NSLocalizedString("Friends of friends", comment: ""), NSLocalizedString("Contacts", comment: "")]
    let segmentedControl = SegmentedControl(titles: titles)
    return segmentedControl
  }()
  let tableView: UITableView = {
    let tableView = UITableView()
    tableView.rowHeight = UserTableViewCell.defaultHeight
    tableView.separatorStyle = .None
    return tableView
  }()
  let searchTextFieldContainer: TextFieldContainerView = {
    let textFieldContainer = TextFieldContainerView(showHintLabel: false, bottomLineHeight: 2)
    textFieldContainer.configureText(hint: nil, placeholder: NSLocalizedString("Find by username", comment: ""))
    textFieldContainer.textField.font = textFieldContainer.textField.font?.fontWithSize(21)
    textFieldContainer.textField.autocapitalizationType = .None
    textFieldContainer.textField.autocorrectionType = .No
    textFieldContainer.textField.spellCheckingType = .No
    textFieldContainer.textField.returnKeyType = .Search
    return textFieldContainer
  }()
  var users = [User]()
  private let addressBook: ABAddressBook? = {
    var error: Unmanaged<CFError>?
    let addressBook = ABAddressBookCreateWithOptions(nil, &error)
    if error != nil {
      print("Address book creation error: \(error)")
      return nil
    }
    return addressBook.takeRetainedValue()
  }()

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.whiteColor()

    title = NSLocalizedString("Find friends", comment: "")
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "top-back-black"), style: .Plain, target: self, action: "leftBarButtonItemPressed")

    view.addSubview(searchTextFieldContainer)
    constrain(searchTextFieldContainer) { searchTextFieldContainer in
      searchTextFieldContainer.top == searchTextFieldContainer.superview!.top + navigationBarOffset
      searchTextFieldContainer.left == searchTextFieldContainer.superview!.left + 20
      searchTextFieldContainer.right == searchTextFieldContainer.superview!.right - 20
      searchTextFieldContainer.height == TextFieldContainerView.defaultHeight
    }

    view.addSubview(segmentedControl)
    constrain(segmentedControl, searchTextFieldContainer) { segmentedControl, searchTextFieldContainer in
      segmentedControl.top == searchTextFieldContainer.bottom + 20
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

    func performRequest(route: SnowballRoute) {
      SnowballAPI.requestObjects(route) { (response: ObjectResponse<[User]>) in
        switch response {
        case .Success(let users):
          self.users = users
          self.tableView.reloadData()
        case .Failure(let error): print(error) // TODO: Handle error
        }
      }
    }

    if segmentedControl.selectedIndex == 0 {
      performRequest(SnowballRoute.FindFriendsOfFriends)
    } else {
      getPhoneNumbersFromAddressBook(
        onSuccess: { (phoneNumbers) -> Void in
          performRequest(SnowballRoute.FindUsersByPhoneNumbers(phoneNumbers: phoneNumbers))
        },
        onFailure: {
          let alertController = UIAlertController(title: NSLocalizedString("Snowball doesn't have access to your contacts. 😭", comment: ""), message: NSLocalizedString("We can take you there now!", comment: ""), preferredStyle: .Alert)
          alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: nil))
          alertController.addAction(UIAlertAction(title: NSLocalizedString("Let's go!", comment: ""), style: .Default,
            handler: { action in
              if let appSettings = NSURL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.sharedApplication().openURL(appSettings)
              }
            })
          )
          self.presentViewController(alertController, animated: true, completion: nil)
        }
      )
    }
  }

  func getPhoneNumbersFromAddressBook(onSuccess onSuccess: (phoneNumbers: [String]) -> Void, onFailure: () -> Void) {
    ABAddressBookRequestAccessWithCompletion(addressBook) { (granted, error) in
      if granted {
        let authorizationStatus = ABAddressBookGetAuthorizationStatus()
        if authorizationStatus != ABAuthorizationStatus.Authorized {
          dispatch_async(dispatch_get_main_queue()) {
            onFailure()
          }
          return
        }
        var phoneNumbers = [String]()
        let contacts = ABAddressBookCopyArrayOfAllPeople(self.addressBook).takeRetainedValue() as NSArray
        for contact in contacts {
          let phoneNumberProperty: AnyObject = ABRecordCopyValue(contact, kABPersonPhoneProperty).takeRetainedValue()
          for var i = 0; i < ABMultiValueGetCount(phoneNumberProperty); i++ {
            let phoneNumber = ABMultiValueCopyValueAtIndex(phoneNumberProperty, i).takeRetainedValue() as! String
            phoneNumbers.append(phoneNumber)
          }
        }
        dispatch_async(dispatch_get_main_queue()) {
          onSuccess(phoneNumbers: phoneNumbers)
        }
      } else {
        dispatch_async(dispatch_get_main_queue()) {
          onFailure()
        }
      }
    }
  }

  // MARK: Actions

  @objc private func leftBarButtonItemPressed() {
    navigationController?.popViewControllerAnimated(true)
  }

  @objc private func segmentedControlValueChanged() {
    refresh()
  }
}

// MARK: - UITableViewDataSource
extension FindFriendsViewController: UITableViewDataSource {
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
extension FindFriendsViewController: UserTableViewCellDelegate {
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