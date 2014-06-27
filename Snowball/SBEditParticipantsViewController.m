//
//  SBEditParticipantsViewController.m
//  Snowball
//
//  Created by James Martinez on 6/26/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBEditParticipantsViewController.h"
#import "SBReel.h"
#import "SBUser.h"
#import "SBUserTableViewCell.h"

@interface SBEditParticipantsViewController ()

@end

@implementation SBEditParticipantsViewController

#pragma mark - SBFollowingViewController

- (void)configureCell:(SBUserTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [super configureCell:cell atIndexPath:indexPath];
    
    [cell setStyle:SBUserTableViewCellStyleSelectable];

    SBUser *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell.checkButton setParticipating:[self.reel.participants containsObject:user]];
}

#pragma mark - SBUserTableViewCellDelegate

- (void)checkUserButtonPressedInCell:(SBUserTableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    SBUser *user = [self.fetchedResultsController objectAtIndexPath:indexPath];

    BOOL participating = [self.reel.participants containsObject:user];
    [cell.checkButton setParticipating:!participating];
    if (participating) {
        // TODO: remove from participating
        // looks something like [user unfollowWithSuccess:nil failure:nil];

    } else {
        // TODO: add to participating
    }
}

@end
