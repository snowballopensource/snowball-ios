//
//  Analytics.swift
//  Snowball
//
//  Created by James Martinez on 2/25/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Foundation

class Analytics {

  // MARK: - Properties

  private class var sharedAnalytics: Analytics {
    struct Singleton {
      static let sharedAnalytics = Analytics()
    }
    return Singleton.sharedAnalytics
  }

  let mixpanel = Mixpanel.sharedInstanceWithToken("38692cce5751bea6cc1628c3b66a915c")

  // MARK: - Internal

  class func track(eventName: String, properties: [String: String]? = nil) {
    println("Tracking event: \(eventName)")
    Analytics.sharedAnalytics.track(eventName, properties: properties)
  }

  class func createAlias(userID: String) {
    Analytics.sharedAnalytics.createAlias(userID)
  }

  class func identify(userID: String) {
    Analytics.sharedAnalytics.identify(userID)
  }

  // MARK: - Private

  private func track(eventName: String, properties: [String: String]? = nil) {

    if let properties = properties {
      mixpanel.track(eventName, properties: properties)
    } else {
      mixpanel.track(eventName)
    }
  }

  private func createAlias(userID: String) {
    mixpanel.createAlias(userID, forDistinctID: mixpanel.distinctId)
  }

  private func identify(userID: String) {
    mixpanel.identify(userID)
  }
}