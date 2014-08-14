//
//  SBFollowingViewController.m
//  Snowball
//
//  Created by James Martinez on 6/26/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBFollowingViewController.h"
#import "SBUser.h"
#import "SBUserTableViewCell.h"

@interface SBFollowingViewController () <SBUserTableViewCellDelegate>

@end

@implementation SBFollowingViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SBUserTableViewCell registerNibToTableView:self.tableView];
    
    [self setEntityClass:[SBUser class]];
    [self setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    [self setPredicate:[NSPredicate predicateWithFormat:@"following == true"]];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SBUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[SBUserTableViewCell identifier]
                                                                forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(SBUserTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [cell setDelegate:self];
    SBUser *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell.nameLabel setText:user.name];
    [cell.userImageView setImageWithURL:[NSURL URLWithString:user.avatarURL]
                       placeholderImage:[SBUserImageView placeholderImageWithInitials:[user.name initials] withSize:cell.userImageView.frame.size]];
    if (user == [SBUser currentUser]) {
        [cell setStyle:SBUserTableViewCellStyleNone];
    } else {
        [cell setStyle:SBUserTableViewCellStyleSelectable];
        [cell.addButton setChecked:user.followingValue];
    }
}

#pragma mark - SBUserTableViewCellDelegate

- (void)userCellSelected:(SBUserTableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    SBUser *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell.addButton setChecked:!user.followingValue];
    if (user.followingValue) {
        [user unfollowWithSuccess:nil failure:nil];
    } else {
        [user followWithSuccess:nil failure:nil];
    }
}

#pragma mark - SBManagedTableViewController

- (void)getRemoteObjects {
    [[SBUser currentUser] getFollowingOnPage:self.currentPage
                                     success:^(BOOL canLoadMore) {
                                         [self setIsLoading:!canLoadMore];
                                         [self.refreshControl endRefreshing];
                                     } failure:^(NSError *error) {
                                         [self.refreshControl endRefreshing];
                                     }];
}

@end
