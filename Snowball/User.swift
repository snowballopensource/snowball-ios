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
  dynamic var color: String = UIColor.blueColor().hexValue

  // MARK: ActiveModel

  override func assignAttributes(attributes: ActiveModelAttributes) {
    if let id = attributes["id"] as? String {
      self.id = id
    }
    if let username = attributes["username"] as? String {
      self.username = username
    }
    if let avatarURL = attributes["avatar_url"] as? String {
      self.avatarURL = avatarURL
    }
    if let following = attributes["following"] as? Bool {
      self.following = following
    }
    if let email = attributes["email"] as? String {
      self.email = email
    }
    if let phoneNumber = attributes["phone_number"] as? String {
      self.phoneNumber = phoneNumber
    }
  }
}