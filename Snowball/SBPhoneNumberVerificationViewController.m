//
//  SBPhoneNumberVerificationViewController.m
//  Snowball
//
//  Created by James Martinez on 9/4/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBAuthenticationNavigationController.h"
#import "SBEditProfileViewController.h"
#import "SBFindFriendsViewController.h"
#import "SBPhoneNumberVerificationViewController.h"

@interface SBPhoneNumberVerificationViewController ()

@end

@implementation SBPhoneNumberVerificationViewController

- (IBAction)verify:(id)sender {
    if ([self.navigationController isKindOfClass:[SBAuthenticationNavigationController class]]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"People" bundle:nil];
        SBFindFriendsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:[SBFindFriendsViewController identifier]];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [self.navigationController.viewControllers each:^(UIViewController *viewController) {
            if ([viewController isKindOfClass:[SBEditProfileViewController class]]) {
                [self.navigationController popToViewController:viewController animated:YES];
                return;
            }
        }];
    }
}

@end
