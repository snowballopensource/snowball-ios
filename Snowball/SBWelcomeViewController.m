//
//  SBWelcomeViewController.m
//  Snowball
//
//  Created by James Martinez on 9/4/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBNewPhoneNumberViewController.h"
#import "SBWelcomeViewController.h"

@interface SBWelcomeViewController ()

@end

@implementation SBWelcomeViewController

- (IBAction)continueOnboarding:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"People" bundle:nil];
    SBNewPhoneNumberViewController *vc = [storyboard instantiateViewControllerWithIdentifier:[SBNewPhoneNumberViewController identifier]];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
