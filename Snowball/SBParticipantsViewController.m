//
//  SBParticipantsViewController.m
//  Snowball
//
//  Created by James Martinez on 6/23/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBParticipantsViewController.h"
#import "SBReel.h"
#import "SBUser.h"
#import "SBUserTableViewCell.h"

@interface SBParticipantsViewController ()

@end

@implementation SBParticipantsViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SBUserTableViewCell registerNibToTableView:self.tableView];
    
    [self setEntityClass:[SBUser class]];
    [self setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]]];
    [self setPredicate:[NSPredicate predicateWithFormat:@"ANY reels == %@", self.reel]];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SBUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[SBUserTableViewCell identifier]
                                                                forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(SBUserTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    SBUser *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell.nameLabel setText:user.name];
    [cell.followButton setHidden:YES];
    [cell.userImageView setImageWithURL:[NSURL URLWithString:user.avatarURL]
                       placeholderImage:[SBUserImageView placeholderImageWithInitials:[user.name initials] withSize:cell.userImageView.frame.size]];
}

#pragma mark - SBManagedTableViewController

- (void)getRemoteObjects {
    [SBReel getParticipantsForReel:self.reel
                            onPage:self.currentPage
                           success:^(BOOL canLoadMore) {
                               [self setIsLoading:!canLoadMore];
                               [self.refreshControl endRefreshing];
                           } failure:^(NSError *error) {
                               [self.refreshControl endRefreshing];
                           }];
}

@end
