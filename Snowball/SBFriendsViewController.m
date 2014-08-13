//
//  SBFriendsViewController.m
//  Snowball
//
//  Created by James Martinez on 8/13/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBFriendsViewController.h"
#import "SBNavigationController.h"
#import "SBReel.h"
#import "SBUser.h"
#import "SBUserTableViewCell.h"

@interface SBFriendsViewController ()

@end

@implementation SBFriendsViewController

#pragma mark - Actions

- (IBAction)switchToReelsStoryboard:(id)sender {
    [(SBNavigationController *)self.navigationController switchToStoryboardWithName:@"Reels"];
}

#pragma mark - SBFollowingViewController

- (void)configureCell:(SBUserTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [super configureCell:cell atIndexPath:indexPath];
    
    [cell setStyle:SBUserTableViewCellStyleFollowable];
}

#pragma mark - SBUserTableViewCellDelegate

- (void)checkUserButtonPressedInCell:(SBUserTableViewCell *)cell {
    NSLog(@"User checked.");
}

@end
