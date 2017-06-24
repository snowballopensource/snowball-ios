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

  dynamic var _id = UUID().uuidString
  dynamic var id: String?
  dynamic var username: String?
  dynamic var avatarURL: String?
  dynamic var following = false
  dynamic var email: String?
  dynamic var phoneNumber: String?
  private dynamic var colorData = NSKeyedArchiver.archivedData(withRootObject: UIColor.SnowballColor.randomColor)
  var color: UIColor {
    get {
      return NSKeyedUnarchiver.unarchiveObject(with: colorData) as? UIColor ?? UIColor.SnowballColor.blueColor
    }
    set {
      colorData = NSKeyedArchiver.archivedData(withRootObject: newValue)
    }
  }
  var authToken: String?

  private static let kCurrentUserIDKey = "CurrentUserID"
  private static let kCurrentUserAuthTokenKey = "CurrentUserAuthToken"
  private static var _currentUser: User?
  static var currentUser: User? {
    get {
      let defaults = UserDefaults.standard
      if let currentUserID = defaults.object(forKey: kCurrentUserIDKey) as? String, let currentUserAuthToken = defaults.object(forKey: kCurrentUserAuthTokenKey) as? String {
        if let _currentUser = _currentUser {
          return _currentUser
        } else {
          let db = Database()
          _currentUser = db.find(currentUserID)
          _currentUser?.authToken = currentUserAuthToken
          return _currentUser
        }
      }
      return nil
    }
    set {
      let defaults = UserDefaults.standard
      if let id = newValue?.id, let authToken = newValue?.authToken {
        defaults.set(id, forKey: kCurrentUserIDKey)
        defaults.set(authToken, forKey: kCurrentUserAuthTokenKey)
        _currentUser = newValue
      } else {
        defaults.removeObject(forKey: kCurrentUserIDKey)
        defaults.removeObject(forKey: kCurrentUserAuthTokenKey)
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

  override func importJSON(_ JSON: JSONObject) {
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
