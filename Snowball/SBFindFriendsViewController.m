//
//  SBFindFriendsViewController.m
//  Snowball
//
//  Created by James Martinez on 6/19/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBAddressBookManager.h"
#import "SBFindFriendsViewController.h"

@interface SBFindFriendsViewController ()

@end

@implementation SBFindFriendsViewController

- (IBAction)findFriendsViaContacts:(id)sender {
    [SBAddressBookManager getAllPhoneNumbersWithCompletion:^(NSArray *phoneNumbers) {
        NSLog(@"Numbers: %@", phoneNumbers);
    }];
}

@end
