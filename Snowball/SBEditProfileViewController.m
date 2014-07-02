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
}

#pragma mark - View Actions

- (IBAction)editProfileImage:(id)sender {
    [UIAlertView bk_showAlertViewWithTitle:@"Hello!" message:@"Haven't finished this yet. :)" cancelButtonTitle:@"Ok" otherButtonTitles:nil handler:nil];
}

- (IBAction)save:(id)sender {
    [UIAlertView bk_showAlertViewWithTitle:@"Hello!" message:@"Haven't finished this yet. :)" cancelButtonTitle:@"Ok" otherButtonTitles:nil handler:nil];
}

@end
