//
//  User.swift
//  Snowball
//
//  Created by James Martinez on 9/17/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Foundation

class User: RLMObject, JSONPersistable {
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
        APICredential.authToken = nil
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

  // MARK: JSONPersistable

  class func possibleJSONKeys() -> [String] {
    return ["user", "users"]
  }

  class func objectFromJSONObject(JSON: JSONObject) -> AnyObject {
    var user: User? = nil
    if let id = JSON["id"] as JSONData? as? String {
      if let existingUser = User.findByID(id) as? User {
        user = existingUser
      } else {
        user = User()
        RLMRealm.defaultRealm().addObject(user)
        user!.id = id
      }
    }
    if let name = JSON["name"] as AnyObject? as? String {
      user!.name = name
    }
    if let username = JSON["username"] as AnyObject? as? String {
      user!.username = username
    }
    if let avatarURL = JSON["avatar_url"] as AnyObject? as? String {
      user!.avatarURL = avatarURL
    }
    if let youFollow = JSON["you_follow"] as AnyObject? as? Bool {
      user!.youFollow = youFollow
    }
    if let email = JSON["email"] as AnyObject? as? String {
      user!.email = email
    }
    if let phoneNumber = JSON["phone_number"] as AnyObject? as? String {
      user!.phoneNumber = phoneNumber
    }
    return user!
  }
}