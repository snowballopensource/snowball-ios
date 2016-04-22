//
//  AuthenticationWelcomeViewController.swift
//  Snowball
//
//  Created by James Martinez on 4/22/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class AuthenticationWelcomeViewController: UIViewController {

  // MARK: Properties

  let logoImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "logo")
    imageView.contentMode = .ScaleAspectFit
    return imageView
  }()

  let backgroundImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "auth-welcome-bg")
    imageView.contentMode = .ScaleAspectFill
    return imageView
  }()

  let signUpButton: UIButton = {
    let button = SnowballActionButton()
    button.setTitle(NSLocalizedString("sign up", comment: ""), forState: .Normal)
    return button
  }()

  let signInButton: UIButton = {
    let button = SnowballActionButton(style: .Bordered)
    button.setTitle(NSLocalizedString("log in", comment: ""), forState: .Normal)
    return button
  }()

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.whiteColor()

    let sideMargin: CGFloat = 30

    view.addSubview(backgroundImageView)
    constrain(backgroundImageView) { backgroundImageView in
      backgroundImageView.left == backgroundImageView.superview!.left
      backgroundImageView.top == backgroundImageView.superview!.top
      backgroundImageView.width == backgroundImageView.superview!.width
      backgroundImageView.bottom == backgroundImageView.superview!.bottom
    }

    view.addSubview(logoImageView)
    constrain(logoImageView) { logoImageView in
      logoImageView.top == logoImageView.superview!.top + 60
      logoImageView.centerX == logoImageView.superview!.centerX
      logoImageView.left == logoImageView.superview!.left + sideMargin
      logoImageView.right == logoImageView.superview!.right - sideMargin
    }

    view.addSubview(signInButton)
    constrain(signInButton) { signInButton in
      signInButton.left == signInButton.superview!.left + sideMargin
      signInButton.right == signInButton.superview!.right - sideMargin
      signInButton.bottom == signInButton.superview!.bottom - sideMargin
      signInButton.height == SnowballActionButton.defaultHeight
    }
    signInButton.addTarget(self, action: #selector(AuthenticationWelcomeViewController.signInButtonPressed), forControlEvents: .TouchUpInside)

    view.addSubview(signUpButton)
    constrain(signUpButton, signInButton) { signUpButton, signInButton in
      signUpButton.left == signInButton.left
      signUpButton.right == signInButton.right
      signUpButton.bottom == signInButton.top - 20
      signUpButton.height == signInButton.height
    }
    signUpButton.addTarget(self, action: #selector(AuthenticationWelcomeViewController.signUpButtonPressed), forControlEvents: .TouchUpInside)
  }

  // MARK: Actions

  @objc func signUpButtonPressed() {
    navigationController?.pushViewController(AuthenticationFormViewController(type: .SignUp), animated: true)
  }

  @objc func signInButtonPressed() {
    navigationController?.pushViewController(AuthenticationFormViewController(type: .SignIn), animated: true)
  }

}