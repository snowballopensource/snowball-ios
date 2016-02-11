//
//  User.swift
//  Snowball
//
//  Created by James Martinez on 12/13/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit

class User: Object {

  // MARK: Properties

  dynamic var id: String?
  dynamic var username: String?
  dynamic var avatarURL: String?
  dynamic var following = false
  dynamic var email: String?
  dynamic var phoneNumber: String?
  private dynamic var colorData = NSKeyedArchiver.archivedDataWithRootObject(UIColor.SnowballColor.randomColor)

  var color: UIColor {
    get {
      return NSKeyedUnarchiver.unarchiveObjectWithData(colorData) as? UIColor ?? UIColor.SnowballColor.blueColor
    }
    set {
      colorData = NSKeyedArchiver.archivedDataWithRootObject(newValue)
    }
  }

  static var currentUser: User? = nil

  // MARK: Object

  override static func primaryKey() -> String? {
    return "id"
  }

  override static func ignoredProperties() -> [String] {
    return ["color"]
  }

  override func importJSON(JSON: JSONObject) {
    if let id = JSON["id"] as? String {
      if self.id == nil {
        self.id = id
      }
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