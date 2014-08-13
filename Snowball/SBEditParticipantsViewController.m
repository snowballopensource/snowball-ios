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
    [cell.checkButton setParticipating:[user isParticipatingInReel:self.reel]];
}

#pragma mark - SBUserTableViewCellDelegate

- (void)checkUserButtonPressedInCell:(SBUserTableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    SBUser *user = [self.fetchedResultsController objectAtIndexPath:indexPath];

    BOOL participating = [user isParticipatingInReel:self.reel];
    [cell.checkButton setParticipating:!participating];
    if (participating) {
        [self.reel removeParticipant:user success:nil failure:nil];

    } else {
        [self.reel addParticipant:user success:nil failure:nil];
    }
}

@end
