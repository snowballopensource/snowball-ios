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

@interface SBFollowingViewController ()

@end

@implementation SBFollowingViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SBUserTableViewCell registerNibToTableView:self.tableView];
    
    [self setEntityClass:[SBUser class]];
    [self setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]];
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
    REQUIRE_SUBCLASS
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
