//
//  SBParticipantsViewController.m
//  Snowball
//
//  Created by James Martinez on 6/23/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBEditParticipantsViewController.h"
#import "SBParticipantsViewController.h"
#import "SBParticipation.h"
#import "SBReel.h"
#import "SBUser.h"
#import "SBUserTableViewCell.h"

typedef NS_ENUM(NSInteger, SBReelDetailsTableViewSection) {
    SBReelDetailsTableViewSectionName,
    SBReelDetailsTableViewSectionParticipants,
    SBReelDetailsTableViewSectionOtherOptions
};

// TODO: rename this to SBReelDetailsViewController
@interface SBParticipantsViewController () <SBUserTableViewCellDelegate>

@end

@implementation SBParticipantsViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [SBUserTableViewCell registerNibToTableView:self.tableView];
    
    [self setEntityClass:[SBParticipation class]];
    [self setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"user.username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]];
    [self setPredicate:[NSPredicate predicateWithFormat:@"reel == %@", self.reel]];
    
    [self setNavBarColor:self.reel.color];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[SBEditParticipantsViewController class]]) {
        SBEditParticipantsViewController *vc = segue.destinationViewController;
        [vc setReel:self.reel];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SBReelDetailsTableViewSectionName:
            return 1;
            break;
        case SBReelDetailsTableViewSectionParticipants: {
            id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections firstObject];
            return [sectionInfo numberOfObjects];
        }
            break;
        case SBReelDetailsTableViewSectionOtherOptions:
            return 1;
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case SBReelDetailsTableViewSectionName: {
#warning This is the incorrect cell. Finish this.
            SBUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[SBUserTableViewCell identifier] forIndexPath:indexPath];
            [self configureCell:cell atIndexPath:indexPath];
            return cell;
        }
            break;
        case SBReelDetailsTableViewSectionParticipants: {
            SBUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[SBUserTableViewCell identifier]
                                                                        forIndexPath:indexPath];
            [self configureCell:cell atIndexPath:indexPath];
            return cell;
        }
            break;
        case SBReelDetailsTableViewSectionOtherOptions: {
#warning This is the incorrect cell. Finish this.
            SBUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[SBUserTableViewCell identifier] forIndexPath:indexPath];
            [self configureCell:cell atIndexPath:indexPath];
            return cell;
        }
            break;
    }
    return nil;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case SBReelDetailsTableViewSectionName: {
#warning This is the incomplete. Finish this.
        }
            break;
        case SBReelDetailsTableViewSectionParticipants: {
            SBUserTableViewCell *_cell = (SBUserTableViewCell *)cell;
            NSIndexPath *offsetIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
            SBParticipation *participation = [self.fetchedResultsController objectAtIndexPath:offsetIndexPath];
            SBUser *user = participation.user;
            [_cell configureForObject:user delegate:self];
            
            [_cell setChecked:[user isParticipatingInReel:self.reel]];
            [_cell setTintColor:self.reel.color];
            
            [_cell setStyle:SBUserTableViewCellStyleNone];
        }
            break;
        case SBReelDetailsTableViewSectionOtherOptions: {
#warning This is the incomplete. Finish this.
        }
            break;
    }
}

#pragma mark - SBUserTableViewCellDelegate

- (void)userCellSelected:(SBUserTableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    SBParticipation *participation = [self.fetchedResultsController objectAtIndexPath:indexPath];
    SBUser *user = participation.user;
    [cell setChecked:!user.followingValue];
    if (user.followingValue) {
        [user unfollowWithSuccess:nil failure:nil];
    } else {
        [user followWithSuccess:nil failure:nil];
    }
}

#pragma mark - SBManagedTableViewController

- (void)getRemoteObjects {
    [self.reel getParticipantsOnPage:self.currentPage
                             success:^(BOOL canLoadMore) {
                                 [self setIsLoading:!canLoadMore];
                                 [self.refreshControl endRefreshing];
                             } failure:^(NSError *error) {
                                 [self.refreshControl endRefreshing];
                             }];
}

@end
