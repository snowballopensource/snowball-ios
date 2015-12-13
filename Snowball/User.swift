//
//  User.swift
//  Snowball
//
//  Created by James Martinez on 12/13/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import RealmSwift
import UIKit

class User: ActiveModel {

  // MARK: Properties

  dynamic var id: String?
  dynamic var username: String?
  dynamic var avatarURL: String?
  dynamic var following = false
  dynamic var email: String?
  dynamic var phoneNumber: String?
  dynamic var color: String?
}