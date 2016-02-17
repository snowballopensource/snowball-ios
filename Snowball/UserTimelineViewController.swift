//
//  UserTimelineViewController.swift
//  Snowball
//
//  Created by James Martinez on 2/17/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Foundation

class UserTimelineViewController: TimelineViewController {

  // MARK: Initializers

  init(user: User) {
    super.init(timelineType: .User(userID: user.id ?? ""))
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}