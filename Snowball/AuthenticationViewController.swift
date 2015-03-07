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

  let tableView = FormTableView()

  var authenticationRoute: Router! { return nil }

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.whiteColor()

    view.addSubview(topBar)
    topBar.setupDefaultLayout()

    let sideMargin: Float = 25

    view.addSubview(messageLabel)
    layout(messageLabel, topBar) { (messageLabel, topBar) in
      messageLabel.left == messageLabel.superview!.left + sideMargin
      messageLabel.top == topBar.bottom
      messageLabel.right == messageLabel.superview!.right - sideMargin
    }

    view.addSubview(tableView)
    layout(tableView, messageLabel) { (tableView, messageLabel) in
      tableView.left == tableView.superview!.left
      tableView.top == messageLabel.bottom
      tableView.right == tableView.superview!.right
      tableView.bottom == tableView.superview!.bottom
    }
  }

  // MARK: - Private

  private func performAuthenticationRequest() {
    API.request(authenticationRoute).responseJSON { (request, response, JSON, error) in
      if error != nil { displayAPIErrorToUser(JSON); return }
      if let userJSON: AnyObject = JSON {
        dispatch_async(dispatch_get_main_queue()) {
          let user = User.objectFromJSON(userJSON) as User?
          user?.managedObjectContext?.save(nil)
          User.currentUser = user
          if let userID = user?.id {
            // TODO: make this configurable by a block or something
            if self.isKindOfClass(SignUpViewController) {
              Analytics.createAliasAndIdentify(userID)
              Analytics.track("Sign Up")
              self.navigationController?.pushViewController(PhoneNumberViewController(), animated: true)
            } else {
              Analytics.identify(userID)
              Analytics.track("Sign In")
              self.switchToNavigationController(MainNavigationController())
            }
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