//
//  AddressBookController.swift
//  Snowball
//
//  Created by James Martinez on 10/7/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import AddressBook
import Foundation

class AddressBookController {
  class var authorized: Bool {
    switch (ABAddressBookGetAuthorizationStatus()) {
      case .Authorized: return true
      default: return false
    }
  }

  class func getAllPhoneNumbersWithCompletion(completion: (Bool, [String]?) -> ()) {
    let addressBook: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
    ABAddressBookRequestAccessWithCompletion(addressBook) { (granted, error) in
      if granted {
        var phoneNumbers = [String]()
        let contacts = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as NSArray
        for contact: ABRecordRef in contacts {
          let contactPhoneNumbers: ABMultiValueRef = ABRecordCopyValue(contact, kABPersonPhoneProperty).takeRetainedValue()
          for var j = 0; j < ABMultiValueGetCount(contactPhoneNumbers); j++ {
            let contactPhoneNumber = ABMultiValueCopyValueAtIndex(contactPhoneNumbers, j).takeRetainedValue() as String
            phoneNumbers.append(contactPhoneNumber)
          }
        }
        completion(granted, phoneNumbers)
      } else {
        completion(granted, nil)
      }
    }
  }
}
