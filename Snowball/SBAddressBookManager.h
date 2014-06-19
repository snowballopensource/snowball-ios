//
//  SBAddressBookManager.h
//  Snowball
//
//  Created by James Martinez on 6/19/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBAddressBookManager : NSObject

+ (void)getAllPhoneNumbersWithCompletion:(void(^)(NSArray *phoneNumbers))completion;

@end
