//
//  SBAuthenticationMenuViewController.m
//  Snowball
//
//  Created by James Martinez on 5/14/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBAuthenticationNavigationController.h"
#import "SBAuthenticationMenuViewController.h"
#import "SBFacebookManager.h"

@interface SBAuthenticationMenuViewController ()

@end

@implementation SBAuthenticationMenuViewController

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    [super viewWillDisappear:animated];
}

#pragma mark - Actions

- (IBAction)authenticateWithFacebook:(id)sender {
    [self showSpinner];
    [SBFacebookManager signInWithSuccess:^{
        [self hideSpinner];
        [(SBAuthenticationNavigationController *)self.navigationController dismiss];
    } failure:^(NSError *error) {
        [error displayInView:self.view];
    }];
}

- (IBAction)showTermsOfService:(id)sender {
    // TODO: implement this
    NSLog(@"Not yet implemented");
}

- (IBAction)showPrivacyPolicy:(id)sender {
    // TODO: implement this
    NSLog(@"Not yet implemented");
}

@end
