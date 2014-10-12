//
//  PhoneNumber.swift
//  Snowball
//
//  Created by James Martinez on 10/11/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import CoreTelephony
import Foundation

struct PhoneNumber {
  let countryCode: String?
  let nationalNumber: String?
  var E164String: String {
    if countryCode != nil && nationalNumber != nil {
      let phoneNumber = (countryCode! + nationalNumber!) as NSString
      if phoneNumber.rangeOfString("+").location == NSNotFound {
        return "+" + phoneNumber
      }
      return phoneNumber
    }
    return ""
  }
  private var defaultRegion: String {
    let networkInfo = CTTelephonyNetworkInfo()
    if let carrier = networkInfo.subscriberCellularProvider {
      return carrier.isoCountryCode
    }
    return "US"
  }

  init(string: String) {
    let phoneUtil = NBPhoneNumberUtil.sharedInstance()
    let phoneNumber = phoneUtil.parse(string, defaultRegion: defaultRegion, error: nil)
    if let phoneNumber = phoneNumber {
      countryCode = phoneNumber.countryCode.stringValue
      nationalNumber = phoneNumber.nationalNumber.stringValue
    } else {
      countryCode = phoneUtil.countryCodeFromRegionCode(defaultRegion)
    }
  }

  func matchesPhoneNumberString(string: String) -> Bool {
    let matchResults = NBPhoneNumberUtil.sharedInstance().isNumberMatch(E164String, second: string, error: nil)
    switch matchResults.value {
      case NBEMatchTypeNOT_A_NUMBER.value: return false
      case NBEMatchTypeNO_MATCH.value: return false
      case NBEMatchTypeSHORT_NSN_MATCH.value: return true
      case NBEMatchTypeNSN_MATCH.value: return true
      case NBEMatchTypeEXACT_MATCH.value: return true
      default: return false
    }
  }

  func isPlausible() -> Bool {
    let phoneUtil = NBPhoneNumberUtil.sharedInstance()
    let phoneNumber = phoneUtil.parse(E164String, defaultRegion: defaultRegion, error: nil)
    return phoneUtil.isPossibleNumber(phoneNumber, error: nil)
  }
}