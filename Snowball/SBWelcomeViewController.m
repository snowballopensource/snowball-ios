//
//  SBWelcomeViewController.m
//  Snowball
//
//  Created by James Martinez on 9/4/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBAuthenticationNavigationController.h"
#import "SBWelcomeViewController.h"

@interface SBWelcomeViewController ()

@end

@implementation SBWelcomeViewController

- (IBAction)continueOnboarding:(id)sender {
    [(SBAuthenticationNavigationController *)self.navigationController dismiss];
}

@end
