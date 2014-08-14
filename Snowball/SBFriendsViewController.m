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

@interface SBFriendsViewController () <SBUserTableViewCellDelegate>

@end

@implementation SBFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSPredicate *currentUserPredicate = [NSPredicate predicateWithFormat:@"remoteID == %@", [SBUser currentUser].remoteID];
    [self setPredicate:[NSCompoundPredicate orPredicateWithSubpredicates:@[self.predicate, currentUserPredicate]]];
    [self setSectionNameKeyPath:@"isCurrentUser"];

    [self setNavBarColor:[UIColor snowballColorBlue]];
}

#pragma mark - SBFollowingViewController

- (void)configureCell:(SBUserTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [super configureCell:cell atIndexPath:indexPath];
    [cell setStyle:SBUserTableViewCellStyleNone];

    SBUser *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UIColor *color = user.color;
    if (user == [SBUser currentUser]) {
        color = [UIColor snowballColorBlue];
    }
    [cell setTintColor:color];
}

#pragma mark - Actions

- (IBAction)switchToReelsStoryboard:(id)sender {
    [(SBNavigationController *)self.navigationController switchToStoryboardWithName:@"Reels"];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
        [headerView.backgroundView setBackgroundColor:[UIColor whiteColor]];
        [headerView.textLabel setFont:[UIFont fontWithName:[UIFont snowballFontNameBook] size:headerView.textLabel.font.pointSize]];
        [headerView.textLabel setTextColor:[UIColor snowballColorBlue]];
    }
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Me";
            break;
    }
    return @"My Friends";
}

@end
