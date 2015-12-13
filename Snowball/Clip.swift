//
//  Clip.swift
//  Snowball
//
//  Created by James Martinez on 12/10/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import Foundation

class Clip: ActiveModel {

  // MARK: Properties

  dynamic var id: String?
  dynamic var videoURL: String?
  dynamic var thumbnailURL: String?
  dynamic var liked = false
  dynamic var createdAt: NSDate?
  dynamic var user: User?
}