//
//  User.swift
//  Snowball
//
//  Created by James Martinez on 9/17/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Foundation

class User: RLMObject {
  dynamic var id = ""
  dynamic var name = ""
  dynamic var username = ""
  dynamic var avatarURL = ""
  dynamic var youFollow = false
  dynamic var email = ""
  dynamic var phoneNumber = ""

  private class var currentUserID: String? {
    get {
      let kCurrentUserIDKey = "CurrentUserID"
      return NSUserDefaults.standardUserDefaults().objectForKey(kCurrentUserIDKey) as String?
    }
    set {
      let kCurrentUserIDKey = "CurrentUserID"
      if let id = newValue {
        NSUserDefaults.standardUserDefaults().setObject(id, forKey: kCurrentUserIDKey)
      } else {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kCurrentUserIDKey)
        API.Credential.authToken = nil
        switchToNavigationController(AuthenticationNavigationController())
      }
      NSUserDefaults.standardUserDefaults().synchronize()
    }
  }

  class var currentUser: User? {
    get {
      if let id = currentUserID {
        return User.findByID(id) as User?
      }
      return nil
    }
    set {
      currentUserID = newValue?.id
    }
  }

  class func currentUserManagedArray() -> RLMArray {
    var id = ""
    if let currentUserID = User.currentUserID {
      id = currentUserID
    }
    return User.objectsWithPredicate(NSPredicate(format: "id == %@", id))
  }

  // MARK: RLMObject

  override func updateFromDictionary(dictionary: [String: AnyObject]) {
    if let id = dictionary["id"] as AnyObject? as? String {
      self.id = id
    }
    if let name = dictionary["name"] as AnyObject? as? String {
      self.name = name
    }
    if let username = dictionary["username"] as AnyObject? as? String {
      self.username = username
    }
    if let avatarURL = dictionary["avatar_url"] as AnyObject? as? String {
      self.avatarURL = avatarURL
    }
    if let youFollow = dictionary["you_follow"] as AnyObject? as? Bool {
      self.youFollow = youFollow
    }
    if let email = dictionary["email"] as AnyObject? as? String {
      self.email = email
    }
    if let phoneNumber = dictionary["phone_number"] as AnyObject? as? String {
      self.phoneNumber = phoneNumber
    }
  }
}