//
//  ProfileTimelineViewController.swift
//  Snowball
//
//  Created by James Martinez on 7/28/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import UIKit

class ProfileTimelineViewController: TimelineViewController {

  // MARK: - Properties

  let user: User

  // MARK: - Initializers

  init(user: User) {
    self.user = user
    super.init(nibName: nil, bundle: nil)
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - TimelineViewController

  override func refresh() {
    timeline.requestUserTimeline(user) { (error) -> Void in
      if let error = error {
        println(error)
        // TODO: Display the error
      }
    }
  }
}

// MARK: - TimelineDelegate
extension ProfileTimelineViewController: TimelineDelegate {

  override func timelineClipsDidLoad() {
    super.timelineClipsDidLoad()

    if let lastClip = timeline.clips.last {
      scrollToClip(lastClip, animated: false)
    }
  }
}