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

  class func signUp(#username: String, email: String, password: String) {
  }
}