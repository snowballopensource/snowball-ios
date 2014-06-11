//
//  SBReelsViewController.m
//  Snowball
//
//  Created by James Martinez on 5/13/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBCameraViewController.h"
#import "SBReel.h"
#import "SBReelClipsViewController.h"
#import "SBReelsViewController.h"
#import "SBReelTableViewCell.h"
#import "SBSessionManager.h"

@interface SBReelsViewController ()

@end

@implementation SBReelsViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SBReelTableViewCell registerNibToTableView:self.tableView];
    
    [self setEntityClass:[SBReel class]];
    [self setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"parsedAt" ascending:YES]]];
    [self setPredicate:[NSPredicate predicateWithFormat:@"homeFeedSession == %@", [SBSessionManager sessionDate]]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *destinationViewController = [segue destinationViewController];
    if ([destinationViewController isKindOfClass:[SBReelClipsViewController class]]) {
        SBReelClipsViewController *reelClipsViewController = [segue destinationViewController];
        SBReel *reel = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
        [reelClipsViewController setReel:reel];
    } else if ([destinationViewController isKindOfClass:[SBCameraViewController class]]) {
        [(SBCameraViewController *)destinationViewController setRecordingCompletionBlock:^(NSURL *fileURL) {
            NSLog(@"Recording completed @ %@", [fileURL path]);
            // TODO: upload video
        }];
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SBReelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[SBReelTableViewCell identifier]
                                                                forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(SBReelTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    SBReel *reel = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell.nameLabel setText:reel.name];
    [cell.posterImageView setImageWithURL:[NSURL URLWithString:[[reel recentClipPosterURLs] firstObject]]];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:[SBReelClipsViewController identifier] sender:self];
}

#pragma mark - SBManagedTableViewController

- (void)getRemoteObjects {
    [SBReel getHomeFeedReelsOnPage:self.currentPage
                           success:^(BOOL canLoadMore){
                               [self setIsLoading:!canLoadMore];
                               [self.refreshControl endRefreshing];
                               [self setFetchedResultsController:nil];
                               [self.tableView reloadData];
                           } failure:^(NSError *error) {
                               [self.refreshControl endRefreshing];
                           }];
}

@end
