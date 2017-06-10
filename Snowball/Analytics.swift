//
//  Analytics.swift
//  Snowball
//
//  Created by James Martinez on 2/25/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Amplitude_iOS
import Foundation

class Analytics {

  // MARK: - Properties

  fileprivate class var sharedAnalytics: Analytics {
    struct Singleton {
      static let sharedAnalytics = Analytics()
    }
    return Singleton.sharedAnalytics
  }

  var amplitude: Amplitude {
    return Amplitude.instance()
  }

  // MARK: - Initializers

  init() {
    Amplitude.instance().initializeApiKey("38e169294d46839c1ce50f44923d6046")
    if let userID = User.currentUser?.id {
      identify(userID)
    }
  }

  // MARK: - Internal

  class func initialize() {
    Analytics.sharedAnalytics
  }

  class func track(_ eventName: String, properties: [String: String]? = nil) {
    Analytics.sharedAnalytics.track(eventName, properties: properties)
  }

  class func identify(_ userID: String) {
    Analytics.sharedAnalytics.identify(userID)
  }

  // MARK: - Private

  fileprivate func track(_ eventName: String, properties: [String: String]? = nil) {
    if isDebug() {
      print("Received but not tracking event: \(eventName)")
    } else {
      print("Tracking event: \(eventName)")
      if let properties = properties {
        amplitude.logEvent(eventName, withEventProperties: properties)
      } else {
        amplitude.logEvent(eventName)
      }
    }
  }

  fileprivate func identify(_ userID: String) {
    if !isDebug() {
      amplitude.setUserId(userID)
    }
  }
}
