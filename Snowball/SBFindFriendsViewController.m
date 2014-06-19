//
//  SBFindFriendsViewController.m
//  Snowball
//
//  Created by James Martinez on 6/19/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBAddressBookManager.h"
#import "SBFindFriendsViewController.h"
#import "SBUser.h"

@interface SBFindFriendsViewController ()

@property (nonatomic, strong) NSArray *users;

@end

@implementation SBFindFriendsViewController

- (IBAction)findFriendsViaContacts:(id)sender {
    [SBAddressBookManager getAllPhoneNumbersWithCompletion:^(NSArray *phoneNumbers) {
        // TODO: make this paginated
        [SBUser findUsersByPhoneNumbers:phoneNumbers
                                   page:0
                                success:^(NSArray *users) {
                                    NSLog(@"%@", users);
                                } failure:^(NSError *error) {
                                    [error displayInView:self.view];
                                }];
    }];
}

@end
