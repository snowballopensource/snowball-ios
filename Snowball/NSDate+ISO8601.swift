//
//  NSDate+ISO8601.swift
//  Snowball
//
//  Created by James Martinez on 7/25/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Foundation

extension NSDate {
  class func dateFromISO8610String(ISO8610String: String) -> NSDate? {
    let dateFormatter = NSDateFormatter()
    dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    dateFormatter.timeZone = NSTimeZone.localTimeZone()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    return dateFormatter.dateFromString(ISO8610String)
  }
}