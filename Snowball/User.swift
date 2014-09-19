//
//  User.swift
//  Snowball
//
//  Created by James Martinez on 9/17/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Foundation

import Alamofire

class User: RLMObject {
  dynamic var id = ""
  dynamic var name = ""
  dynamic var username = ""
  dynamic var avatarURL = ""
  dynamic var email = ""
  dynamic var phoneNumber = ""

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
    if let email = dictionary["email"] as AnyObject? as? String {
      self.email = email
    }
    if let phoneNumber = dictionary["phone_number"] as AnyObject? as? String {
      self.phoneNumber = phoneNumber
    }
  }
}

class UserAPI {
  class func signUp(#username: String, email: String, password: String, success: successClosure?, failure: failureClosure?) {
  }

  class func signIn(#email: String, password: String, success: successClosure?, failure: failureClosure?) {

  }

  class func getCurrentUser(success: successClosure?, failure: failureClosure?) {
    Alamofire.request(.GET, "http://private-78d57-snowballapi.apiary-mock.com/api/v1/users/me").responseJSON { (request, response, data, error) in
      if (error != nil) { failure!(error!); return }
      if let JSON = data as? [String: AnyObject] {
        if let _user = JSON["user"] as AnyObject? as? [String: AnyObject] {
          Realm.saveInBackground({ (realm) in
            User.createOrUpdateFromDictionary(_user, inRealm: realm)
            return
          }, completionClosure: {
            if (success != nil) { success!(); return }
          })
        }
      }
    }
  }

  class func updateCurrentUser(success: successClosure?, failure: failureClosure?) {

  }

  class func getCurrentUserFollowing(success: successClosure?, failure: failureClosure?) {

  }

  class func followUser(user: User, success: successClosure?, failure: failureClosure?) {

  }

  class func unfollowUser(user: User, success: successClosure?, failure: failureClosure?) {

  }

  class func findUsersByPhoneNumbers(phoneNumbers: [String], success: successClosure?, failure: failureClosure?) {

  }

}