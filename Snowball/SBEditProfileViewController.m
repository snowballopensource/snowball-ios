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
@property (nonatomic, weak) IBOutlet UITextField *bioTextField;
@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) IBOutlet UITextField *phoneTextField;


@end

@implementation SBEditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView setBackgroundColor:[UIColor whiteColor]];

    [self setBackButtonStyle:UIViewControllerBackButtonStyleDark];

    SBUser *user = [SBUser currentUser];
    UIImage *placeholderImage = [SBUserImageView placeholderImageWithInitials:user.name.initials
                                                                     withSize:self.userImageView.bounds.size];
    [self.userImageView setImageWithURL:[NSURL URLWithString:user.avatarURL]
                       placeholderImage:placeholderImage];
    [self.usernameTextField setText:user.username];
    [self.nameTextField setText:user.name];
    [self.bioTextField setText:user.bio];
    [self.emailTextField setText:user.email];
    [self.phoneTextField setText:user.phoneNumber];
}

#pragma mark - View Actions

- (IBAction)editProfileImage:(id)sender {
    [UIAlertView bk_showAlertViewWithTitle:@"Hello!" message:@"Haven't finished this yet. :)" cancelButtonTitle:@"Ok" otherButtonTitles:nil handler:nil];
}

- (IBAction)save:(id)sender {
    [UIAlertView bk_showAlertViewWithTitle:@"Hello!" message:@"Haven't finished this yet. :)" cancelButtonTitle:@"Ok" otherButtonTitles:nil handler:nil];
}

@end
