//
//  SBSignInViewController.m
//  Snowball
//
//  Created by James Martinez on 5/14/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBAuthenticationNavigationController.h"
#import "SBSignInViewController.h"
#import "SBUser.h"

@interface SBSignInViewController ()

@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;

@end

@implementation SBSignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
#if DEBUG
    [self.emailTextField setText:@"blackhole@snowball.is"];
    [self.passwordTextField setText:@"something"];
#endif
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else {
        [self signIn:textField];
    }
    return YES;
}

#pragma mark - Actions

- (IBAction)signIn:(id)sender {
    [self showSpinner];
    [SBUser signInWithEmail:self.emailTextField.text
                   password:self.passwordTextField.text
                    success:^{
                        [self hideSpinner];
                        [(SBAuthenticationNavigationController *)self.navigationController dismiss];
                    }
                    failure:^(NSError *error) {
                        [self hideSpinner];
                        [error displayInView:self.view];
                    }];
}

@end
