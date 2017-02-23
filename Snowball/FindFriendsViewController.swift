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
    let titles = [NSLocalizedString("Contacts", comment: ""), NSLocalizedString("Recommended", comment: "")]
    let segmentedControl = SegmentedControl(titles: titles)
    return segmentedControl
  }()
  let tableView: UITableView = {
    let tableView = UITableView()
    tableView.rowHeight = UserTableViewCell.defaultHeight
    tableView.separatorStyle = .None
    return tableView
  }()
  private let tableViewTopConstraintGroup = ConstraintGroup()
  let searchTextField: FormTextField = {
    let textField = FormTextField()
    textField.placeholder = NSLocalizedString("Find by username", comment: "")
    textField.font = textField.font?.fontWithSize(21)
    textField.autocapitalizationType = .None
    textField.autocorrectionType = .No
    textField.spellCheckingType = .No
    textField.returnKeyType = .Search
    return textField
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
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "top-back-black"), style: .Plain, target: self, action: #selector(FindFriendsViewController.leftBarButtonItemPressed))

    view.addSubview(searchTextField)
    constrain(searchTextField) { searchTextField in
      searchTextField.top == searchTextField.superview!.top + navigationBarOffset
      searchTextField.left == searchTextField.superview!.left + 20
      searchTextField.right == searchTextField.superview!.right - 20
      searchTextField.height == FormTextField.defaultHeight
    }
    searchTextField.delegate = self

    view.addSubview(segmentedControl)
    constrain(segmentedControl, searchTextField) { segmentedControl, searchTextField in
      segmentedControl.top == searchTextField.bottom + 20
      segmentedControl.left == segmentedControl.superview!.left + 17
      segmentedControl.right == segmentedControl.superview!.right - 17
      segmentedControl.height == 35
    }
    segmentedControl.addTarget(self, action: #selector(FindFriendsViewController.segmentedControlValueChanged), forControlEvents: .ValueChanged)

    view.addSubview(tableView)
    constrain(tableView) { tableView in
      tableView.left == tableView.superview!.left
      tableView.bottom == tableView.superview!.bottom
      tableView.right == tableView.superview!.right
    }
    setTableViewTopConstraint()
    tableView.dataSource = self
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    performUserRequest()
  }

  // MARK: Private

  private func performUserRequest(search search: String? = nil) {
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

    if let search = search {
      performRequest(SnowballRoute.FindUsersByUsername(username: search))
    } else {
      if segmentedControl.selectedIndex == 1 {
        performRequest(SnowballRoute.FindRecommendedUsers)
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
  }

  private func getPhoneNumbersFromAddressBook(onSuccess onSuccess: (phoneNumbers: [String]) -> Void, onFailure: () -> Void) {
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
          for i in 0 ..< ABMultiValueGetCount(phoneNumberProperty) {
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

  private func setTableViewTopConstraint(coveringSegmentedControl coveringSegmentedControl: Bool = false) {
    if coveringSegmentedControl {
      constrain(tableView, segmentedControl, replace: tableViewTopConstraintGroup) { tableView, segmentedControl in
        tableView.top == segmentedControl.top
      }
    } else {
      constrain(tableView, segmentedControl, replace: tableViewTopConstraintGroup) { tableView, segmentedControl in
        tableView.top == segmentedControl.bottom + 10
      }
    }
    view.layoutIfNeeded()
  }

  // MARK: Actions

  @objc private func leftBarButtonItemPressed() {
    navigationController?.popViewControllerAnimated(true)
  }

  @objc private func segmentedControlValueChanged() {
    performUserRequest()
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
    guard user.id != nil else { return }

    followForUser(user) { following in
      cell.followButton.setFollowing(following, animated: true)
    }
  }
}

func followForUser(user: User, completion: (Bool) -> Void) {
  let followingCurrently = user.following

  func setFollowing(following: Bool) {
    Database.performTransaction {
      user.following = following
      Database.save(user)
    }
    completion(following)
  }

  setFollowing(!followingCurrently)

  let route: SnowballRoute
  if followingCurrently {
    route = SnowballRoute.UnfollowUser(userID: user.id!)
    Analytics.track("Unfollow User")
  } else {
    route = SnowballRoute.FollowUser(userID: user.id!)
    Analytics.track("Follow User")
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

extension FindFriendsViewController: UITextFieldDelegate {
  func textFieldDidBeginEditing(textField: UITextField) {
    setTableViewTopConstraint(coveringSegmentedControl: true)
  }

  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if let search = textField.text {
      performUserRequest(search: search)
    }
    textField.resignFirstResponder()
    return true
  }
}
