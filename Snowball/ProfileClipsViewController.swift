//
//  ProfileClipsViewController.swift
//  Snowball
//
//  Created by James Martinez on 4/23/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Foundation

class ProfileClipsViewController: ClipsViewController {

  // MARK: - Properties

  private let user: User

  // MARK: - Initializers

  init(user: User) {
    self.user = user
    super.init(nibName: nil, bundle: nil)
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - ClipsViewController

  override func refresh() {
    if let userID = user.id {
      activityIndicatorView.startAnimating()
      API.request(Router.GetClipStreamForUser(userID: userID)).responseJSON { (request, response, JSON, error) in
        if let JSON = JSON as? [AnyObject] {
          self.clips = Clip.importJSON(JSON)
          self.collectionView.reloadData()
        }
        self.activityIndicatorView.stopAnimating()
      }
    }
  }
}