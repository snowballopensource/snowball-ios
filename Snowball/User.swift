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

  dynamic var _id = NSUUID().UUIDString
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
  var authToken: String?

  private static let kCurrentUserIDKey = "CurrentUserID"
  private static let kCurrentUserAuthTokenKey = "CurrentUserAuthToken"
  private static var _currentUser: User?
  static var currentUser: User? {
    get {
      let defaults = NSUserDefaults.standardUserDefaults()
      if let currentUserID = defaults.objectForKey(kCurrentUserIDKey) as? String, let currentUserAuthToken = defaults.objectForKey(kCurrentUserAuthTokenKey) as? String {
        if let _currentUser = _currentUser {
          return _currentUser
        } else {
          _currentUser = Database.find(currentUserID)
          _currentUser?.authToken = currentUserAuthToken
          return _currentUser
        }
      }
      return nil
    }
    set {
      let defaults = NSUserDefaults.standardUserDefaults()
      if let id = newValue?.id, authToken = newValue?.authToken {
        defaults.setObject(id, forKey: kCurrentUserIDKey)
        defaults.setObject(authToken, forKey: kCurrentUserAuthTokenKey)
        _currentUser = newValue
      } else {
        defaults.removeObjectForKey(kCurrentUserIDKey)
        defaults.removeObjectForKey(kCurrentUserAuthTokenKey)
        _currentUser = nil
      }
      defaults.synchronize()
    }
  }

  // MARK: Object

  override static func primaryKey() -> String? {
    return "_id"
  }

  override static func ignoredProperties() -> [String] {
    return ["color", "authToken"]
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
    if let authToken = JSON["auth_token"] as? String {
      self.authToken = authToken
    }
  }
}