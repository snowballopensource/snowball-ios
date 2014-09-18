//
//  User.swift
//  Snowball
//
//  Created by James Martinez on 9/17/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Foundation

class User: RLMObject {
  dynamic var name = ""
  dynamic var username = ""
  dynamic var avatarURL = ""
  dynamic var email = ""
  dynamic var phoneNumber = ""
}

class UserAPI {
  class func signUp(#username: String, email: String, password: String, success: successClosure?, failure: failureClosure?) {

  }

  class func signIn(#email: String, password: String, success: successClosure?, failure: failureClosure?) {

  }

  class func getCurrentUser(success: successClosure?, failure: failureClosure?) {

  }

  class func updateCurrentUser(success: successClosure?, failure: failureClosure?) {

  }

  class func getCurrentUserFollowing(success: successClosure?, failure: failureClosure?) {

  }

  class func followUser(user: User, success: successClosure?, failure: failureClosure?) {

  }

  class func unfollowUser(user: User, success: successClosure?, failure: failureClosure?) {

  }

  typealias successClosureWithUsers = ([User]?) -> ()
  class func findUsersByPhoneNumbers(phoneNumbers: [String], success: successClosureWithUsers?, failure: failureClosure?) {
    let users = [User]()
    if (success != nil) { success!(users) }
  }

}