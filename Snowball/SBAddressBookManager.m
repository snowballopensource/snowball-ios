//
//  SBAddressBookManager.m
//  Snowball
//
//  Created by James Martinez on 6/19/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBAddressBookManager.h"

#import <AddressBook/AddressBook.h>

@implementation SBAddressBookManager

+ (void)getAllPhoneNumbersWithCompletion:(void(^)(NSArray *phoneNumbers))completion {
    [self requestAddressBookAccessWithCompletion:^(BOOL granted) {
        if (granted) {
            NSMutableArray *phoneNumbers = [@[] mutableCopy];
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(0, nil);
            CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
            CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
            for (int i = 0; i < numberOfPeople; i++) {
                ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
                ABMultiValueRef personNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
                for (CFIndex i = 0; i < ABMultiValueGetCount(personNumbers); i++) {
                    NSString *number = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(personNumbers, i);
                    [phoneNumbers addObject:number];
                }
            }
            completion(phoneNumbers);
        } else {
            [self showNoAccessAlert];
        }
    }];
}

+ (void)requestAddressBookAccessWithCompletion:(void(^)(BOOL granted))completion {
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(0, nil);
    switch (ABAddressBookGetAuthorizationStatus()) {
        case kABAuthorizationStatusNotDetermined: {
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                completion(granted);
            });
        }
            break;
        case kABAuthorizationStatusAuthorized: {
            completion(YES);
        }
            break;
        default: {
            completion(NO);
        }
            break;
    }
}

+ (void)showNoAccessAlert {
    // User has denied access
    // TODO: show an alert telling user to change privacy setting in settings app
}

@end
