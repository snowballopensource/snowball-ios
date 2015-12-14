//
//  NSError+Snowball.swift
//  Snowball
//
//  Created by James Martinez on 12/13/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import Foundation

extension NSError {
  static func snowballErrorWithReason(reason: String?) -> NSError {
    let domain = "is.snowball.snowball.error"
    if let reason = reason {
      return NSError(domain: domain, code: 0, userInfo: [NSLocalizedFailureReasonErrorKey: reason])
    }
    return NSError(domain: domain, code: 0, userInfo: nil)
  }
}