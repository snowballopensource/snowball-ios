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