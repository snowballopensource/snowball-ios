//
//  Analytics.swift
//  Snowball
//
//  Created by James Martinez on 2/25/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Amplitude_iOS
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

  var amplitude: Amplitude {
    return Amplitude.instance()
  }

  var mixpanel: Mixpanel {
    return Mixpanel.sharedInstance()
  }

  // MARK: - Initializers

  init() {
    Amplitude.instance().initializeApiKey("38e169294d46839c1ce50f44923d6046")
    Mixpanel.sharedInstanceWithToken("38692cce5751bea6cc1628c3b66a915c")
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
      print("Received but not tracking event: \(eventName)")
    } else {
      print("Tracking event: \(eventName)")
      if let properties = properties {
        amplitude.logEvent(eventName, withEventProperties: properties)
        mixpanel.track(eventName, properties: properties)
      } else {
        amplitude.logEvent(eventName)
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
      amplitude.setUserId(userID)
    }
  }
}