//
//  SBParticipantsViewController.m
//  Snowball
//
//  Created by James Martinez on 6/23/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBEditReelNameViewController.h"
#import "SBEditParticipantsViewController.h"
#import "SBParticipantsViewController.h"
#import "SBReel.h"
#import "SBUser.h"
#import "SBUserTableViewCell.h"

typedef NS_ENUM(NSInteger, SBReelDetailsTableViewSection) {
    SBReelDetailsTableViewSectionName,
    SBReelDetailsTableViewSectionParticipants,
    SBReelDetailsTableViewSectionOtherOptions
};

// TODO: rename this to SBReelDetailsViewController
@interface SBParticipantsViewController () <SBUserTableViewCellDelegate, UIAlertViewDelegate>

@end

@implementation SBParticipantsViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [SBUserTableViewCell registerNibToTableView:self.tableView];
    [SBTableViewCell registerClassToTableView:self.tableView];
    
    [self setEntityClass:[SBUser class]];
    [self setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]];
    [self setPredicate:[NSPredicate predicateWithFormat:@"reels CONTAINS[cd] %@", self.reel]];
    
    [self setNavBarColor:self.reel.color];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[SBEditParticipantsViewController class]]) {
        SBEditParticipantsViewController *vc = segue.destinationViewController;
        [vc setReel:self.reel];
    }
    if ([segue.destinationViewController isKindOfClass:[SBEditReelNameViewController class]]) {
        SBEditReelNameViewController *vc = segue.destinationViewController;
        [vc setReel:self.reel];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Reload row name
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:SBReelDetailsTableViewSectionName]] withRowAnimation:UITableViewRowAnimationAutomatic];
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
            id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[[self controller:self.fetchedResultsController originalSectionIndexFromMappedSectionIndex:section]];
            return [sectionInfo numberOfObjects] + 1;
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
            SBTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[SBTableViewCell identifier] forIndexPath:indexPath];
            [self configureCell:cell atIndexPath:indexPath];
            return cell;
        }
            break;
        case SBReelDetailsTableViewSectionParticipants: {
            id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[[self controller:self.fetchedResultsController originalSectionIndexFromMappedSectionIndex:indexPath.section]];
            if (indexPath.row == [sectionInfo numberOfObjects]) {
                SBTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[SBTableViewCell identifier] forIndexPath:indexPath];
                [self configureCell:cell atIndexPath:indexPath];
                return cell;
            } else {
                SBUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[SBUserTableViewCell identifier]
                                                                            forIndexPath:indexPath];
                [self configureCell:cell atIndexPath:indexPath];
                return cell;
            }
        }
            break;
        case SBReelDetailsTableViewSectionOtherOptions: {
            SBTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[SBTableViewCell identifier] forIndexPath:indexPath];
            [self configureCell:cell atIndexPath:indexPath];
            return cell;
        }
            break;
    }
    return nil;
}

- (void)configureCell:(SBTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [cell.textLabel setFont:[UIFont fontWithName:[UIFont snowballFontNameBook] size:20]];
    [cell setTintColor:self.reel.color];

    switch (indexPath.section) {
        case SBReelDetailsTableViewSectionName: {
            [cell.textLabel setText:self.reel.name];
        }
            break;
        case SBReelDetailsTableViewSectionParticipants: {
            id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[[self controller:self.fetchedResultsController originalSectionIndexFromMappedSectionIndex:indexPath.section]];
            if (indexPath.row == [sectionInfo numberOfObjects]) {
                [cell.textLabel setText:@"Add friends..."];
                UIImage *image = [UIImage imageNamed:@"cell-plus"];
                UIImageView *accessoryView = [[UIImageView alloc] initWithImage:image];
                [accessoryView setImageTintColor:self.reel.color];
                [cell setAccessoryView:accessoryView];
            } else {
                SBUserTableViewCell *_cell = (SBUserTableViewCell *)cell;
                NSIndexPath *offsetIndexPath = [self controller:self.fetchedResultsController originalIndexPathFromMappedIndexPath:indexPath];
                SBUser *user = [self.fetchedResultsController objectAtIndexPath:offsetIndexPath];
                [_cell configureForObject:user delegate:self];

                [_cell setTintColor:self.reel.color];
                
                [_cell setChecked:[user isParticipatingInReel:self.reel]];
                
                [_cell setStyle:SBUserTableViewCellStyleNone];
            }
        }
            break;
        case SBReelDetailsTableViewSectionOtherOptions: {
            [cell setTintColor:[UIColor redColor]];
            [cell.textLabel setText:@"Exit group"];
        }
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case SBReelDetailsTableViewSectionName:
            return @"Subject";
            break;
        case SBReelDetailsTableViewSectionParticipants:
            return @"Participants";
            break;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case SBReelDetailsTableViewSectionName:
            [self performSegueWithIdentifier:[SBEditReelNameViewController identifier] sender:self];
            break;
        case SBReelDetailsTableViewSectionParticipants:
            [self performSegueWithIdentifier:[SBEditParticipantsViewController identifier] sender:self];
            break;
        case SBReelDetailsTableViewSectionOtherOptions: {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to leave?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Leave", nil];
            [alertView show];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    unless (buttonIndex == [alertView cancelButtonIndex]) {
        [self showSpinner];
        [self.reel leaveGroupWithSuccess:^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        } failure:^(NSError *error) {
            [error displayInView:self.view];
        }];
    }
}

#pragma mark - NSFetchedResultsController Custom Mapping

- (NSUInteger)controller:(NSFetchedResultsController *)controller mappedSectionIndexFromOriginalSectionIndex:(NSUInteger)originalSectionIndex {
    return SBReelDetailsTableViewSectionParticipants;
}

- (NSUInteger)controller:(NSFetchedResultsController *)controller originalSectionIndexFromMappedSectionIndex:(NSUInteger)mappedSectionIndex {
    return 0;
}

- (NSIndexPath *)controller:(NSFetchedResultsController *)controller mappedIndexPathFromOriginalIndexPath:(NSIndexPath *)originalIndexPath {
    return [NSIndexPath indexPathForRow:originalIndexPath.row inSection:SBReelDetailsTableViewSectionParticipants];
}

- (NSIndexPath *)controller:(NSFetchedResultsController *)controller originalIndexPathFromMappedIndexPath:(NSIndexPath *)mappedIndexPath {
    return [NSIndexPath indexPathForRow:mappedIndexPath.row inSection:0];
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
