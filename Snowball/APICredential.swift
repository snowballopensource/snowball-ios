//
//  APICredential.swift
//  Snowball
//
//  Created by James Martinez on 9/30/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Foundation

struct APICredential {
  static let kCurrentUserAuthTokenKey = "CurrentUserAuthToken"
  static var authToken: String? {
    get {
      return NSUserDefaults.standardUserDefaults().objectForKey(kCurrentUserAuthTokenKey) as String?
    }
    set {
      if let authToken = newValue {
        NSUserDefaults.standardUserDefaults().setObject(authToken, forKey: kCurrentUserAuthTokenKey)
      } else {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kCurrentUserAuthTokenKey)
      }
      NSUserDefaults.standardUserDefaults().synchronize()
    }
  }
}