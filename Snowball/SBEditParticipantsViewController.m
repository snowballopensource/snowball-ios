//
//  SBEditParticipantsViewController.m
//  Snowball
//
//  Created by James Martinez on 6/26/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBEditParticipantsViewController.h"
#import "SBFindFriendsViewController.h"
#import "SBReel.h"
#import "SBUser.h"
#import "SBUserTableViewCell.h"

@interface SBEditParticipantsViewController () <SBUserTableViewCellDelegate>

@end

@implementation SBEditParticipantsViewController

#pragma mark - View Actions

- (IBAction)findFriends:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"People" bundle:nil];
    SBFindFriendsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:[SBFindFriendsViewController identifier]];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - SBFollowingViewController

- (void)configureCell:(SBUserTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    SBUser *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell configureForObject:user delegate:self];
    
    [cell setChecked:[user isParticipatingInReel:self.reel]];
    [cell setTintColor:self.reel.color];
}

#pragma mark - SBUserTableViewCellDelegate

- (void)userCellSelected:(SBUserTableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    SBUser *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    BOOL participating = [user isParticipatingInReel:self.reel];
    [cell setChecked:!participating];
    if (participating) {
        [self.reel removeParticipant:user success:nil failure:nil];
    } else {
        [self.reel addParticipant:user success:nil failure:nil];
    }
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"My friends";
            break;
    }
    return nil;
}

@end
