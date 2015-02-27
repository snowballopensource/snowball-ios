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

  // MARK: - Properties

  @NSManaged var id: String?
  @NSManaged var name: String?
  @NSManaged var username: String?
  @NSManaged var avatarURL: String?
  @NSManaged var following: NSNumber
  @NSManaged var email: String?
  @NSManaged var phoneNumber: String?
  @NSManaged var color: AnyObject
  var authToken: String?

  // MARK: Current User

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

  override func assignAttributes(attributes: [String: AnyObject]) {
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
    if let email = attributes["email"] as? String {
      self.email = email
    }
    if let phoneNumber = attributes["phone_number"] as? String {
      self.phoneNumber = phoneNumber
    }
    if let authToken = attributes["auth_token"] as? String {
      self.authToken = authToken
    }
  }

  // MARK: - Internal

  func toggleFollowing() {
    if following.boolValue {
      unfollow()
    } else {
      follow()
    }
  }

  // MARK: - Private

  private func follow() {
    if let userID = id {
      Analytics.track("Follow User")
      following = true
      managedObjectContext?.save(nil)

      API.request(Router.FollowUser(userID: userID)).responseJSON { (request, response, JSON, error) in
        if let error = error {
          error.print("follow")
          displayAPIErrorToUser(JSON)
          self.following = false
          self.managedObjectContext?.save(nil)
        }
      }
    }
  }

  private func unfollow() {
    if let userID = id {
      following = false
      managedObjectContext?.save(nil)

      API.request(Router.UnfollowUser(userID: userID)).responseJSON { (request, response, JSON, error) in
        if let error = error {
          error.print("unfollow")
          displayAPIErrorToUser(JSON)
          self.following = true
          self.managedObjectContext?.save(nil)
        }
      }
    }
  }
}