//
//  Analytics.swift
//  Snowball
//
//  Created by James Martinez on 2/25/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Foundation
import Mixpanel

class Analytics {

  // MARK: - Properties

  private class var sharedAnalytics: Analytics {
    struct Singleton {
      static let sharedAnalytics = Analytics()
    }
    return Singleton.sharedAnalytics
  }

  let mixpanel = Mixpanel.sharedInstanceWithToken("38692cce5751bea6cc1628c3b66a915c")

  // MARK: - Initializers

  init() {
    if let userID = User.currentUser?.id {
      identify(userID)
    }
  }

  // MARK: - Internal

  class func track(eventName: String, properties: [String: String]? = nil) {
    Analytics.sharedAnalytics.track(eventName, properties: properties)
  }

  class func createAliasAndIdentify(userID: String) {
    Analytics.sharedAnalytics.createAliasAndIdentify(userID)
  }

  class func identify(userID: String) {
    Analytics.sharedAnalytics.identify(userID)
  }

  // MARK: - Private

  private func track(eventName: String, properties: [String: String]? = nil) {
    if isStaging() {
      println("Received but not tracking event: \(eventName)")
    } else {
      println("Tracking event: \(eventName)")
      if let properties = properties {
        mixpanel.track(eventName, properties: properties)
      } else {
        mixpanel.track(eventName)
      }
    }
  }

  private func createAliasAndIdentify(userID: String) {
    if !isStaging() {
      mixpanel.createAlias(userID, forDistinctID: mixpanel.distinctId)
      identify(userID)
    }
  }

  private func identify(userID: String) {
    if !isStaging() {
      mixpanel.identify(userID)
      mixpanel.registerSuperProperties(["User ID": userID])
    }
  }
}