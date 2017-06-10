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
    tableView.separatorStyle = .none
    return tableView
  }()
  private let tableViewTopConstraintGroup = ConstraintGroup()
  let searchTextField: FormTextField = {
    let textField = FormTextField()
    textField.placeholder = NSLocalizedString("Find by username", comment: "")
    textField.font = textField.font?.withSize(21)
    textField.autocapitalizationType = .none
    textField.autocorrectionType = .no
    textField.spellCheckingType = .no
    textField.returnKeyType = .search
    return textField
  }()
  var users = [User]()
  private let addressBook: ABAddressBook? = {
    var error: Unmanaged<CFError>?
    let addressBook = ABAddressBookCreateWithOptions(nil, &error)
    if let error = error {
      print("Address book creation error: \(error)")
      return nil
    }
    return addressBook?.takeRetainedValue()
  }()

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.white

    title = NSLocalizedString("Find friends", comment: "")
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "top-back-black"), style: .plain, target: self, action: #selector(FindFriendsViewController.leftBarButtonItemPressed))

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
    segmentedControl.addTarget(self, action: #selector(FindFriendsViewController.segmentedControlValueChanged), for: .valueChanged)

    view.addSubview(tableView)
    constrain(tableView) { tableView in
      tableView.left == tableView.superview!.left
      tableView.bottom == tableView.superview!.bottom
      tableView.right == tableView.superview!.right
    }
    setTableViewTopConstraint()
    tableView.dataSource = self
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    performUserRequest()
  }

  // MARK: Private

  fileprivate func performUserRequest(search: String? = nil) {
    self.users.removeAll()
    self.tableView.reloadData()

    func performRequest(_ route: SnowballRoute) {
      SnowballAPI.requestObjects(route) { (response: ObjectResponse<[User]>) in
        switch response {
        case .success(let users):
          self.users = users
          self.tableView.reloadData()
        case .failure(let error): print(error) // TODO: Handle error
        }
      }
    }

    if let search = search {
      performRequest(SnowballRoute.findUsersByUsername(username: search))
    } else {
      if segmentedControl.selectedIndex == 1 {
        performRequest(SnowballRoute.findRecommendedUsers)
      } else {
        getPhoneNumbersFromAddressBook(
          onSuccess: { (phoneNumbers) -> Void in
            performRequest(SnowballRoute.findUsersByPhoneNumbers(phoneNumbers: phoneNumbers))
          },
          onFailure: {
            let alertController = UIAlertController(title: NSLocalizedString("Snowball doesn't have access to your contacts. 😭", comment: ""), message: NSLocalizedString("We can take you there now!", comment: ""), preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Let's go!", comment: ""), style: .default,
              handler: { action in
                if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
                  UIApplication.shared.openURL(appSettings)
                }
            })
            )
            self.present(alertController, animated: true, completion: nil)
          }
        )
      }
    }
  }

  private func getPhoneNumbersFromAddressBook(onSuccess: @escaping (_ phoneNumbers: [String]) -> Void, onFailure: @escaping () -> Void) {
    ABAddressBookRequestAccessWithCompletion(addressBook) { (granted, error) in
      if granted {
        let authorizationStatus = ABAddressBookGetAuthorizationStatus()
        if authorizationStatus != ABAuthorizationStatus.authorized {
          DispatchQueue.main.async {
            onFailure()
          }
          return
        }
        var phoneNumbers = [String]()
        let contacts = ABAddressBookCopyArrayOfAllPeople(self.addressBook).takeRetainedValue() as NSArray
        for contact in contacts {
          let phoneNumberProperty: AnyObject = ABRecordCopyValue(contact as ABRecord, kABPersonPhoneProperty).takeRetainedValue()
          for i in 0 ..< ABMultiValueGetCount(phoneNumberProperty) {
            let phoneNumber = ABMultiValueCopyValueAtIndex(phoneNumberProperty, i).takeRetainedValue() as! String
            phoneNumbers.append(phoneNumber)
          }
        }
        DispatchQueue.main.async {
          onSuccess(phoneNumbers)
        }
      } else {
        DispatchQueue.main.async {
          onFailure()
        }
      }
    }
  }

  fileprivate func setTableViewTopConstraint(coveringSegmentedControl: Bool = false) {
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
    navigationController?.popViewController(animated: true)
  }

  @objc private func segmentedControlValueChanged() {
    performUserRequest()
  }
}

// MARK: - UITableViewDataSource
extension FindFriendsViewController: UITableViewDataSource {
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

// MARK: - UserTableViewCellDelegate
extension FindFriendsViewController: UserTableViewCellDelegate {
  func userTableViewCellFollowButtonTapped(_ cell: UserTableViewCell) {
    guard let indexPath = tableView.indexPath(for: cell) else { return }
    let user = users[indexPath.row]
    guard user.id != nil else { return }

    followForUser(user) { following in
      cell.followButton.setFollowing(following, animated: true)
    }
  }
}

func followForUser(_ user: User, completion: @escaping (Bool) -> Void) {
  let followingCurrently = user.following

  func setFollowing(_ following: Bool) {
    Database.performTransaction {
      user.following = following
      Database.save(user)
    }
    completion(following)
  }

  setFollowing(!followingCurrently)

  let route: SnowballRoute
  if followingCurrently {
    route = SnowballRoute.unfollowUser(userID: user.id!)
    Analytics.track("Unfollow User")
  } else {
    route = SnowballRoute.followUser(userID: user.id!)
    Analytics.track("Follow User")
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

extension FindFriendsViewController: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    setTableViewTopConstraint(coveringSegmentedControl: true)
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if let search = textField.text {
      performUserRequest(search: search)
    }
    textField.resignFirstResponder()
    return true
  }
}
