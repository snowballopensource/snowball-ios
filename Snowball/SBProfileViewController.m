//
//  SBProfileViewController.m
//  Snowball
//
//  Created by James Martinez on 5/23/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBProfileViewController.h"
#import "SBUser.h"
#import "SBUserImageView.h"

@interface SBProfileViewController ()

@property (nonatomic, weak) IBOutlet UIBarButtonItem *menuButton;
@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *bioLabel;
@property (nonatomic, weak) IBOutlet SBUserImageView *avatar;

@property (nonatomic, weak) IBOutlet UIButton *editProfileButton;

@end

@implementation SBProfileViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.editProfileButton setHidden:YES];
    
    if (!self.user) {
        [self setUser:[SBUser currentUser]];
    }
    
    [self updateUIFromUser];
    
    [self.user getWithSuccess:^{
        [self updateUIFromUser];
    } failure:^(NSError *error) {
        [error displayInView:self.view];
    }];
    
    if ([self.navigationController.viewControllers firstObject] != self) {
        [self.menuButton setHidden:YES];
    }
}

#pragma mark - Actions

- (IBAction)editProfile:(id)sender {
    [UIAlertView bk_showAlertViewWithTitle:@"Not implemented." message:nil cancelButtonTitle:@"OK" otherButtonTitles:nil handler:nil];
}

#pragma mark - Private

- (void)updateUIFromUser {
    if (self.user == [SBUser currentUser]) {
        [self.editProfileButton setHidden:NO];
    }
    [self.usernameLabel setText:self.user.username];
    [self.nameLabel setText:self.user.name];
    [self.bioLabel setText:self.user.bio];
    [self.avatar setImageWithURL:[NSURL URLWithString:self.user.avatarURL]
                placeholderImage:[SBUserImageView placeholderImageWithInitials:[self.user.name initials] withSize:self.avatar.frame.size]];
}

@end
