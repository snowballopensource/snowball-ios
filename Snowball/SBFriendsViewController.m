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

typedef NS_ENUM(NSInteger, SBReelDetailsTableViewSection) {
    SBFriendsTableViewSectionMe,
    SBFriendsTableViewSectionFriends
};

@interface SBFriendsViewController () <SBUserTableViewCellDelegate>

@end

@implementation SBFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setNavBarColor:[UIColor snowballColorBlue]];
}

#pragma mark - SBFollowingViewController

- (void)configureCell:(SBUserTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    SBUser *user = nil;
    switch (indexPath.section) {
        case SBFriendsTableViewSectionMe:
            user = [SBUser currentUser];
            break;
        case SBFriendsTableViewSectionFriends: {
            NSIndexPath *offsetIndexPath = [self controller:self.fetchedResultsController originalIndexPathFromMappedIndexPath:indexPath];
            user = [self.fetchedResultsController objectAtIndexPath:offsetIndexPath];
        }
            break;
    }

    [cell configureForObject:user delegate:self];
    [cell setStyle:SBUserTableViewCellStyleNone];
}

#pragma mark - Actions

- (IBAction)switchToReelsStoryboard:(id)sender {
    [(SBNavigationController *)self.navigationController switchToStoryboardWithName:@"Reels"];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SBFriendsTableViewSectionMe:
            return 1;
            break;
        case SBFriendsTableViewSectionFriends: {
            id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[[self controller:self.fetchedResultsController originalSectionIndexFromMappedSectionIndex:section]];
            return [sectionInfo numberOfObjects];
        }
            break;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case SBFriendsTableViewSectionMe:
            return @"Me";
            break;
        case SBFriendsTableViewSectionFriends:
            return @"My Friends";
            break;
    }
    return nil;
}

#pragma mark - NSFetchedResultsController Custom Mapping

- (NSUInteger)controller:(NSFetchedResultsController *)controller mappedSectionIndexFromOriginalSectionIndex:(NSUInteger)originalSectionIndex {
    return SBFriendsTableViewSectionFriends;
}

- (NSUInteger)controller:(NSFetchedResultsController *)controller originalSectionIndexFromMappedSectionIndex:(NSUInteger)mappedSectionIndex {
    return 0;
}

- (NSIndexPath *)controller:(NSFetchedResultsController *)controller mappedIndexPathFromOriginalIndexPath:(NSIndexPath *)originalIndexPath {
    return [NSIndexPath indexPathForRow:originalIndexPath.row inSection:SBFriendsTableViewSectionFriends];
}

- (NSIndexPath *)controller:(NSFetchedResultsController *)controller originalIndexPathFromMappedIndexPath:(NSIndexPath *)mappedIndexPath {
    return [NSIndexPath indexPathForRow:mappedIndexPath.row inSection:0];
}

#pragma mark - SBUserTableViewCellDelegate

- (void)editProfileButtonTapped {
    [self performSegueWithIdentifier:@"SBEditProfileViewController" sender:self];
}

@end
