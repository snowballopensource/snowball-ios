//
//  UIViewController+Authentication.swift
//  Snowball
//
//  Created by James Martinez on 10/22/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

extension UIViewController {
  func authenticateUser(ifAuthenticated: () -> Void) {
    if User.currentUser == nil {
      let authenticationNC = AuthenticationNavigationController()
      authenticationNC.transitioningDelegate = AuthenticationPresentationControllerTransitioningDelegate.sharedInstance
      authenticationNC.modalPresentationStyle = .Custom
      presentViewController(authenticationNC, animated: true, completion: nil)
    } else {
      ifAuthenticated()
    }
  }
}

// MARK: -

class AuthenticationPresentationController: UIPresentationController {

  // MARK: - Properties

  let dimView: UIView = {
    let view = UIView()
    view.alpha = 0
    view.backgroundColor = UIColor(white: 0, alpha: 0.5)
    return view
    }()

  let cancelButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(named: "top-bar-x")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
    button.imageView?.tintColor = UIColor.blackColor()
    return button
    }()

  // MARK: - UIPresentationController

  override init(presentedViewController: UIViewController, presentingViewController: UIViewController) {
    super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)

    presentedView()?.addSubview(cancelButton)
    constrain(cancelButton) { cancelButton in
      cancelButton.centerX == cancelButton.superview!.centerX
      cancelButton.top == cancelButton.superview!.top
      cancelButton.width == 44
      cancelButton.height == 65
    }
    cancelButton.addTarget(self, action: "cancelButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)

    presentedView()?.layer.cornerRadius = 10.0
    presentedView()?.layer.masksToBounds = true
  }

  override func presentationTransitionWillBegin() {
    dimView.frame = containerView!.bounds
    containerView?.addSubview(dimView)

    presentedViewController.transitionCoordinator()?.animateAlongsideTransition(
      { _ in
        self.dimView.alpha = 1
      },
      completion: nil)
  }

  override func dismissalTransitionWillBegin() {
    presentedViewController.transitionCoordinator()?.animateAlongsideTransition(
      { _ in
        self.dimView.alpha = 0
      },
      completion: { _ in
        self.dimView.removeFromSuperview()
    })
  }

  override func frameOfPresentedViewInContainerView() -> CGRect {
    return CGRectInset(containerView!.bounds, 20, 20)
  }

  // MARK: - Private

  @objc private func cancelButtonPressed() {
    presentedViewController.dismissViewControllerAnimated(true, completion: nil)
  }
}

// MARK: -

class AuthenticationPresentationControllerTransitioningDelegate: NSObject {
  static let sharedInstance = AuthenticationPresentationControllerTransitioningDelegate()
}

// MARK: - UIViewControllerTransitioningDelegate
extension AuthenticationPresentationControllerTransitioningDelegate: UIViewControllerTransitioningDelegate {
  func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
    return AuthenticationPresentationController(presentedViewController: presented, presentingViewController: presenting)
  }
}