//
//  AuthenticationViewController.swift
//  Snowball
//
//  Created by James Martinez on 1/13/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class AuthenticationViewController: UIViewController {

  // MARK: - Properties

  private let topBar = SnowballTopView(leftButtonType: SnowballTopViewButtonType.Back, rightButtonType: SnowballTopViewButtonType.Forward)

  let messageLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: UIFont.SnowballFont.regular, size: 24)
    label.numberOfLines = 2
    return label
  }()

  private let tableViewController = FormTableViewController()

  var tableView: UITableView {
    return tableViewController.tableView
  }

  var authenticationRoute: Router! { return nil }

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.whiteColor()

    view.addSubview(topBar)
    topBar.setupDefaultLayout()

    let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 70))
    let sideMargin: CGFloat = 25
    tableHeaderView.addSubview(messageLabel)
    layout(messageLabel) { (messageLabel) in
      messageLabel.left == messageLabel.superview!.left + sideMargin
      messageLabel.top == messageLabel.superview!.top
      messageLabel.right == messageLabel.superview!.right - sideMargin
    }
    tableView.tableHeaderView = tableHeaderView

    addChildViewController(tableViewController)
    view.addSubview(tableViewController.view)
    tableViewController.didMoveToParentViewController(self)
    layout(tableViewController.view, topBar) { (tableView, topBar) in
      tableView.left == tableView.superview!.left
      tableView.top == topBar.bottom
      tableView.right == tableView.superview!.right
      tableView.bottom == tableView.superview!.bottom
    }
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    if let firstCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? TextFieldTableViewCell {
      firstCell.textField.becomeFirstResponder()
    }
  }

  // MARK: - Internal

  func authenticationCompletedSuccessfully(user: User) {
    PushManager.associateCurrentInstallationWithCurrentUser(true)
  }

  // MARK: - Private

  private func performAuthenticationRequest() {
    resignFirstResponder()
    topBar.spinRightButton(true)
    API.request(authenticationRoute).responseJSON { (request, response, JSON, error) in
      if error != nil {
        displayAPIErrorToUser(JSON)
        self.topBar.spinRightButton(false)
        return
      }
      if let userJSON: AnyObject = JSON {
        dispatch_async(dispatch_get_main_queue()) {
          let user = User.objectFromJSON(userJSON) as! User?
          user?.managedObjectContext?.save(nil)
          User.currentUser = user
          if let user = user {
            self.authenticationCompletedSuccessfully(user)
          }
        }
      }
    }
  }
}

// MARK: -

extension AuthenticationViewController: SnowballTopViewDelegate {

  // MARK: - SnowballTopViewDelegate

  func snowballTopViewLeftButtonTapped() {
    navigationController?.popViewControllerAnimated(true)
  }

  func snowballTopViewRightButtonTapped() {
    performAuthenticationRequest()
  }
}

// MARK: - UITextFieldDelegate
extension AuthenticationViewController: UITextFieldDelegate {
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    for cell in tableView.visibleCells {
      if let cell = cell as? TextFieldTableViewCell {
        if textField.isDescendantOfView(cell.contentView) {
          if let indexPath = tableView.indexPathForCell(cell) {
            if let nextCell = tableView.cellForRowAtIndexPath(NSIndexPath(forItem: indexPath.row + 1, inSection: indexPath.section)) as? TextFieldTableViewCell {
              nextCell.textField.becomeFirstResponder()
            } else {
              performAuthenticationRequest()
            }
          }
        }
      }
    }
    return false
  }
}