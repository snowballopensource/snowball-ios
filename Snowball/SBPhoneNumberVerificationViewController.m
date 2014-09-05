//
//  SBPhoneNumberVerificationViewController.m
//  Snowball
//
//  Created by James Martinez on 9/4/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBEditProfileViewController.h"
#import "SBPhoneNumberVerificationViewController.h"

@interface SBPhoneNumberVerificationViewController ()

@end

@implementation SBPhoneNumberVerificationViewController

- (IBAction)verify:(id)sender {
    [self.navigationController.viewControllers each:^(UIViewController *viewController) {
        if ([viewController isKindOfClass:[SBEditProfileViewController class]]) {
            [self.navigationController popToViewController:viewController animated:YES];
        }
    }];
}

@end
