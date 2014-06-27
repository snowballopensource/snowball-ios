//
//  SBEditParticipantsViewController.m
//  Snowball
//
//  Created by James Martinez on 6/26/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBEditParticipantsViewController.h"
#import "SBUser.h"
#import "SBUserTableViewCell.h"

@interface SBEditParticipantsViewController ()

@end

@implementation SBEditParticipantsViewController

#pragma mark - SBFollowingViewController

- (void)configureCell:(SBUserTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [super configureCell:cell atIndexPath:indexPath];
    [cell setStyle:SBUserTableViewCellStyleSelectable];
    // TODO: set selected if user is a participant
    [cell.checkButton setParticipating:YES];
}

#pragma mark - SBUserTableViewCellDelegate

- (void)checkUserButtonPressedInCell:(SBUserTableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    SBUser *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    // TODO: set cell participating if user is a participant
    NSLog(@"Not done yet.");
    // should look something like this:
    
    /*
     [cell.followButton setFollowing:!user.followingValue];
     if (user.followingValue) {
     [user unfollowWithSuccess:nil failure:nil];
     } else {
     [user followWithSuccess:nil failure:nil];
     }
     }
     */
}

@end
