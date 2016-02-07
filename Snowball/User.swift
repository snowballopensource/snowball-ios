//
//  User.swift
//  Snowball
//
//  Created by James Martinez on 12/13/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import UIKit

class User: ActiveModel {

  // MARK: Properties

  dynamic var id: String?
  dynamic var username: String?
  dynamic var avatarURL: String?
  dynamic var following = false
  dynamic var email: String?
  dynamic var phoneNumber: String?
  dynamic var colorHex: String?

  var color: UIColor {
    guard let colorHex = colorHex else { return UIColor.SnowballColor.blueColor }
    return UIColor(hex: colorHex)
  }

  static var currentUser: User? = nil

  // MARK: ActiveModel

  override func importJSON(JSON: JSONObject) {
    if let id = JSON["id"] as? String {
      self.id = id
    }
    if let username = JSON["username"] as? String {
      self.username = username
    }
    if let avatarURL = JSON["avatar_url"] as? String {
      self.avatarURL = avatarURL
    }
    if let following = JSON["following"] as? Bool {
      self.following = following
    }
    if let email = JSON["email"] as? String {
      self.email = email
    }
    if let phoneNumber = JSON["phone_number"] as? String {
      self.phoneNumber = phoneNumber
    }
  }
}