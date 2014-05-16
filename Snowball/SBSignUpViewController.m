//
//  SBSignUpViewController.m
//  Snowball
//
//  Created by James Martinez on 5/14/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBAuthenticationNavigationController.h"
#import "SBSignUpViewController.h"
#import "SBUser.h"

@interface SBSignUpViewController ()

@property (nonatomic, weak) IBOutlet UITextField *usernameTextField;
@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;

@end

@implementation SBSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
#if DEBUG
    [self.usernameTextField setText:@"snowballdev"];
    [self.emailTextField setText:@"blackhole@snowball.is"];
    [self.passwordTextField setText:@"something"];
#endif
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.usernameTextField) {
        [self.emailTextField becomeFirstResponder];
    } else if (textField == self.emailTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else {
        [self signUp:textField];
    }
    return YES;
}

#pragma mark - Actions

- (IBAction)signUp:(id)sender {
    // [self showSpinner];
    [SBUser signUpWithUsername:self.usernameTextField.text
                         email:self.emailTextField.text
                      password:self.passwordTextField.text
                       success:^{
                           // [self hideSpinner];
                           [(SBAuthenticationNavigationController *)self.navigationController dismiss];
                       }
                       failure:^(NSError *error) {
                           // [self hideSpinner];
                           // [error displayInView:self.view];
                       }];
}

@end
