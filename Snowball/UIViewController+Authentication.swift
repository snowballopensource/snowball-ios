//
//  UIViewController+Authentication.swift
//  Snowball
//
//  Created by James Martinez on 2/25/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Cartography
import Foundation
import UIKit

extension UIViewController {
  func authenticateUser(afterSuccessfulAuthentication afterSuccessfulAuthentication: (() -> Void)?, whenAlreadyAuthenticated: (() -> Void)?) {
    if User.currentUser == nil {
      let authenticationNC = RoundedCornerViewController(childViewController: AuthenticationNavigationController())
      let transitioningDelegate = AuthenticationPresentationControllerTransitioningDelegate.sharedInstance
      transitioningDelegate.onComplete = {
        if User.currentUser != nil {
          afterSuccessfulAuthentication?()
        }
      }
      authenticationNC.transitioningDelegate = transitioningDelegate
      authenticationNC.modalPresentationStyle = .Custom
      presentViewController(authenticationNC, animated: true, completion: nil)
    } else {
      whenAlreadyAuthenticated?()
    }
  }
}

// MARK: - RoundedCornerViewController
private class RoundedCornerViewController: UIViewController {

  init(childViewController: UIViewController) {
    super.init(nibName: nil, bundle: nil)

    addChildViewController(childViewController)
    let childView = childViewController.view
    view.addSubview(childView)
    constrain(childView) { childView in
      childView.left == childView.superview!.left
      childView.top == childView.superview!.top
      childView.right == childView.superview!.right
      childView.bottom == childView.superview!.bottom
    }
    childViewController.didMoveToParentViewController(self)

    childView.layer.cornerRadius = 10
    childView.clipsToBounds = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - AuthenticationPresentationController
private class AuthenticationPresentationController: UIPresentationController {

  // MARK: Properties

  let dimView: UIView = {
    let view = UIView()
    view.alpha = 0
    view.backgroundColor = UIColor(white: 0, alpha: 0.5)
    return view
  }()

  let cancelButton: UIButton = {
    let button = UIButton()
    button.backgroundColor = UIColor.whiteColor()
    button.layer.cornerRadius = 22
    button.clipsToBounds = true
    button.setImage(UIImage(named: "top-x-small"), forState: UIControlState.Normal)
    return button
  }()

  // MARK: UIPresentationController

  override init(presentedViewController: UIViewController, presentingViewController: UIViewController) {
    super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)

    guard let presentedView = presentedView() else { return }

    presentedView.addSubview(cancelButton)
    constrain(cancelButton) { cancelButton in
      cancelButton.centerX == cancelButton.superview!.centerX
      cancelButton.top == cancelButton.superview!.top - 10
      cancelButton.width == 44
      cancelButton.height == 44
    }
    cancelButton.addTarget(self, action: #selector(AuthenticationPresentationController.cancelButtonPressed), forControlEvents: UIControlEvents.TouchUpInside)
  }

  override func presentationTransitionWillBegin() {
    guard let containerView = containerView else { return }

    dimView.frame = containerView.bounds
    containerView.addSubview(dimView)

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
        if let transitioningDelegate = self.presentedViewController.transitioningDelegate as? AuthenticationPresentationControllerTransitioningDelegate {
          transitioningDelegate.onComplete?()
        }
    })
  }

  override func frameOfPresentedViewInContainerView() -> CGRect {
    return CGRectInset(containerView!.bounds, 20, 20)
  }

  // MARK: Private

  @objc private func cancelButtonPressed() {
    presentedViewController.dismissViewControllerAnimated(true, completion: nil)
  }
}

// MARK: AuthenticationPresentationControllerTransitioningDelegate
class AuthenticationPresentationControllerTransitioningDelegate: NSObject {
  static let sharedInstance = AuthenticationPresentationControllerTransitioningDelegate()
  var onComplete: (() -> Void)? = nil
}

// MARK: - UIViewControllerTransitioningDelegate
extension AuthenticationPresentationControllerTransitioningDelegate: UIViewControllerTransitioningDelegate {
  func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
    return AuthenticationPresentationController(presentedViewController: presented, presentingViewController: presenting)
  }
}