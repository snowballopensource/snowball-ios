//
//  OnboardingSignInViewController.swift
//  Snowball
//
//  Created by James Martinez on 1/13/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import UIKit

class OnboardingSignInViewController: OnboardingAuthenticationViewController {

  // MARK: - OnboardingAuthenticationViewController

  override func goForward() {
    if validateFields() {
      let route = Router.SignIn(email: emailTextField.text, password: passwordTextField.text)
      API.request(route).responseJSON { (request, response, JSON, error) in
        if error != nil { displayAPIErrorToUser(JSON); return }
        if let userJSON: AnyObject = JSON {
          CoreRecord.saveWithBlock { (context) in
            let user = User.objectFromJSON(userJSON, context: context) as User?
            User.currentUser = user
            if let user = user {
              dispatch_async(dispatch_get_main_queue()) {
                AppDelegate.switchToNavigationController(MainNavigationController())
              }
            }
          }
        }
      }
    }
  }
}