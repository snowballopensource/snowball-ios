//
//  SBEditProfileViewController.m
//  Snowball
//
//  Created by James Martinez on 6/30/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBEditProfileViewController.h"
#import "SBUser.h"
#import "SBUserImageView.h"

@interface SBEditProfileViewController ()

@property (nonatomic, weak) IBOutlet SBUserImageView *userImageView;

@property (nonatomic, weak) IBOutlet UITextField *usernameTextField;
@property (nonatomic, weak) IBOutlet UITextField *nameTextField;
@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) IBOutlet UITextField *phoneTextField;

@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *tintableViews;

@end

@implementation SBEditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupBackButton];
    
    [self setTintColor:[UIColor snowballColorBlue]];
    
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    
    SBUser *user = [SBUser currentUser];
    [self showSpinner];
    [user getWithSuccess:^{
        [self.userImageView setImageWithUser:user];
        [self.usernameTextField setText:user.username];
        [self.nameTextField setText:user.name];
        [self.emailTextField setText:user.email];
        [self.phoneTextField setText:user.phoneNumber];
        [self hideSpinner];
    } failure:^(NSError *error) {
        [self hideSpinner];
        [error displayInView:self.view];
    }];
}

- (void)setTintColor:(UIColor *)tintColor {
    for (UIView *view in self.tintableViews) {
        if ([view isKindOfClass:[UIButton class]]) {
            [(UIButton *)view setImageTintColor:tintColor];
        } else {
            [(UIImageView *)view setImageTintColor:tintColor];
        }
    }
    [self.usernameTextField setTextColor:tintColor];
    [self.nameTextField setTextColor:tintColor];
    [self.emailTextField setTextColor:tintColor];
    [self.phoneTextField setTextColor:tintColor];
}

#pragma mark - View Actions

- (IBAction)editProfileImage:(id)sender {
    // TODO: allow profile image editing
    [UIAlertView bk_showAlertViewWithTitle:@"Hello!" message:@"Haven't finished this yet. :)" cancelButtonTitle:@"Ok" otherButtonTitles:nil handler:nil];
}

- (IBAction)save:(id)sender {
    if (self.usernameTextField.text.length == 0) {
        [UIAlertView bk_showAlertViewWithTitle:@"Whoops!"
                                       message:@"Please enter a username."
                             cancelButtonTitle:@"Ok"
                             otherButtonTitles:nil
                                       handler:nil];
    } else if (self.emailTextField.text.length == 0) {
        [UIAlertView bk_showAlertViewWithTitle:@"Whoops!"
                                       message:@"Please enter your email address."
                             cancelButtonTitle:@"Ok"
                             otherButtonTitles:nil
                                       handler:nil];
    } else {
        [self showSpinner];
        SBUser *user = [SBUser currentUser];
        [user setName:self.nameTextField.text];
        [user setUsername:self.usernameTextField.text];
        [user setEmail:self.emailTextField.text];
        [user setPhoneNumber:self.phoneTextField.text];
        [user updateWithSuccess:^{
            [self hideSpinner];
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSError *error) {
            [self hideSpinner];
            [error displayInView:self.view];
        }];
    }
}

@end
