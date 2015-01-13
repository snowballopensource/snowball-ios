//
//  User.swift
//  Snowball
//
//  Created by James Martinez on 12/6/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import CoreData
import UIKit

class User: RemoteObject {
  @NSManaged var id: String?
  @NSManaged var name: String?
  @NSManaged var username: String?
  @NSManaged var avatarURL: String?
  @NSManaged var following: NSNumber
  @NSManaged var clips: NSSet
  @NSManaged var color: AnyObject
  var authToken: String?

  // MARK: - Current User

  // Since stored class variables are not yet supported,
  // we create a struct that does support static vars.
  // https://github.com/hpique/SwiftSingleton#approach-b-nested-struct

  private struct CurrentUserStruct {
    static var currentUser: User?
    static let kCurrentUserAuthTokenKey = "CurrentUserAuthToken"
    static let kCurrentUserIDKey = "CurrentUserID"
    static let kCurrentUserChangedNotificationName = "CurrentUserChangedNotification"
  }

  class var currentUser: User? {
    get {
      if (CurrentUserStruct.currentUser == nil) {
        let defaults = NSUserDefaults.standardUserDefaults()
        let currentUserID = defaults.objectForKey(CurrentUserStruct.kCurrentUserIDKey) as String?
        if currentUserID == nil {
          return nil
        }
        let currentUserAuthToken = defaults.objectForKey(CurrentUserStruct.kCurrentUserAuthTokenKey) as String?
        if currentUserAuthToken == nil {
          return nil
        }
        CurrentUserStruct.currentUser = User.find(currentUserID!) as User?
        CurrentUserStruct.currentUser?.authToken = currentUserAuthToken
      }
      return CurrentUserStruct.currentUser
    }
    set(user) {
      let defaults = NSUserDefaults.standardUserDefaults()
      if user?.id == nil || user?.authToken == nil {
        CurrentUserStruct.currentUser = nil
        defaults.removeObjectForKey(CurrentUserStruct.kCurrentUserIDKey)
      } else {
        defaults.setObject(user?.id, forKey: CurrentUserStruct.kCurrentUserIDKey)
        defaults.setObject(user?.authToken, forKey: CurrentUserStruct.kCurrentUserAuthTokenKey)
        CurrentUserStruct.currentUser = user
      }
      defaults.synchronize()
      NSNotificationCenter.defaultCenter().postNotificationName(CurrentUserStruct.kCurrentUserChangedNotificationName, object: user)
    }
  }

  // MARK: - NSManagedObject

  override func awakeFromInsert() {
    super.awakeFromInsert()
    color = UIColor.SnowballColor.randomColor
  }

  override func assign(attributes: AnyObject) {
    if let id = attributes["id"] as? String {
      self.id = id
    }
    if let name = attributes["name"] as? String {
      self.name = name
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
  }
}