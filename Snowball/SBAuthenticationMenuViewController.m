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
#import "SBWebViewController.h"

@interface SBAuthenticationMenuViewController ()

@property (nonatomic, weak) IBOutlet UIButton *termsButton;
@property (nonatomic, weak) IBOutlet UIButton *privacyButton;

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    if ([segue.destinationViewController isKindOfClass:[SBWebViewController class]]) {
        SBWebViewController *vc = segue.destinationViewController;
        if (sender == self.termsButton) {
            [vc setUrl:[NSURL URLWithString:@"http://snowball.is/terms"]];
        } else if (sender == self.privacyButton) {
            [vc setUrl:[NSURL URLWithString:@"http://snowball.is/privacy"]];
        }
    }
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

@end
