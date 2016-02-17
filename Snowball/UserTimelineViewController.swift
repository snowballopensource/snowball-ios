//
//  UserTimelineViewController.swift
//  Snowball
//
//  Created by James Martinez on 2/17/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Cartography
import Foundation
import UIKit

class UserTimelineViewController: TimelineViewController {

  // MARK: Properties

  let topBackgroundImageView = UIImageView()
  let user: User

  // MARK: Initializers

  init(user: User) {
    self.user = user
    super.init(timelineType: .User(userID: user.id ?? ""))
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(topBackgroundImageView)
    constrain(topBackgroundImageView) { topBackgroundImageView in
      topBackgroundImageView.left == topBackgroundImageView.superview!.left
      topBackgroundImageView.top == topBackgroundImageView.superview!.top
      topBackgroundImageView.right == topBackgroundImageView.superview!.right
      topBackgroundImageView.height == topBackgroundImageView.superview!.width
    }
    if let avatarURLString = user.avatarURL, avatarURL = NSURL(string: avatarURLString) {
      topBackgroundImageView.setImageFromURL(avatarURL)
    }
  }
}