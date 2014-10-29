//
//  User.swift
//  Snowball
//
//  Created by James Martinez on 9/17/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Foundation
import UIKit

class User: RemoteManagedObject, JSONPersistable {
  dynamic var name = ""
  dynamic var username = ""
  dynamic var avatarURL = ""
  dynamic var youFollow = false
  dynamic var email = ""
  dynamic var phoneNumber = ""
  dynamic var colorHex = UIColor.randomColor().hex()

  var color: UIColor {
    get {
      return UIColor(hex: colorHex)
    }
  }

  var initials: String {
    get {
      func initials(string: String) -> String {
        let words = string.componentsSeparatedByString(" ")
        var initials = [String]()
        for word in words {
          initials.append(word.substringToIndex(advance(word.startIndex, 1)))
        }
        return "".join(initials)
      }
      if countElements(name) > 0 {
        return initials(name)
      }
      return initials(username)
    }
  }

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
        return User.findByID(id)
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

  class func following() -> RLMArray {
    return User.objectsWithPredicate(NSPredicate(format: "youFollow == true"))
  }

  // MARK: JSONPersistable

  class func objectFromJSONObject(JSON: JSONObject) -> Self? {
    if let id = JSON["id"] as JSONData? as? String {
      var user = findOrInitializeByID(id)

      if let name = JSON["name"] as JSONData? as? String {
        user.name = name
      }
      if let username = JSON["username"] as JSONData? as? String {
        user.username = username
      }
      if let avatarURL = JSON["avatar_url"] as JSONData? as? String {
        user.avatarURL = avatarURL
      }
      if let youFollow = JSON["you_follow"] as JSONData? as? Bool {
        user.youFollow = youFollow
      }
      if let email = JSON["email"] as JSONData? as? String {
        user.email = email
      }
      if let phoneNumber = JSON["phone_number"] as JSONData? as? String {
        user.phoneNumber = phoneNumber
      }

      return user
    }
    return nil
  }
}