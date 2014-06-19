//
//  SBReelsViewController.m
//  Snowball
//
//  Created by James Martinez on 5/13/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBCameraViewController.h"
#import "SBCreateReelViewController.h"
#import "SBReel.h"
#import "SBReelClipsViewController.h"
#import "SBReelsViewController.h"
#import "SBReelTableViewCell.h"
#import "SBSessionManager.h"
#import "SBUser.h"

@interface SBReelsViewController ()

@property (nonatomic, strong) NSURL *recordingURL;

@end

@implementation SBReelsViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SBReelTableViewCell registerNibToTableView:self.tableView];
    
    [self setEntityClass:[SBReel class]];
    [self setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO]]];
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
            [self setRecordingURL:fileURL];
            [self performSegueWithIdentifier:[SBCreateReelViewController identifier] sender:self];
        }];
    } else if ([destinationViewController isKindOfClass:[SBCreateReelViewController class]]) {
        [(SBCreateReelViewController *)destinationViewController setInitialRecordingURL:self.recordingURL];
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

    if ([reel.recentParticipants count] > 0) {
        NSString *imageOneURLString = [(SBUser *)[reel.recentParticipants firstObject] avatarURL];
        [cell.participantOneImageView setBackgroundColor:[UIColor lightGrayColor]];
        [cell.participantOneImageView setImageWithURL:[NSURL URLWithString:imageOneURLString]];
    }
    if ([reel.recentParticipants count] > 1) {
        NSString *imageTwoURLString = [(SBUser *)[reel.recentParticipants objectAtIndex:1] avatarURL];
        [cell.participantTwoImageView setBackgroundColor:[UIColor lightGrayColor]];
        [cell.participantTwoImageView setImageWithURL:[NSURL URLWithString:imageTwoURLString]];
    }
    if ([reel.recentParticipants count] > 2) {
        NSString *imageThreeURLString = [(SBUser *)[reel.recentParticipants objectAtIndex:2] avatarURL];
        [cell.participantThreeImageView setBackgroundColor:[UIColor lightGrayColor]];
        [cell.participantThreeImageView setImageWithURL:[NSURL URLWithString:imageThreeURLString]];
    }
    if ([reel.recentParticipants count] > 3) {
        NSString *imageFourURLString = [(SBUser *)[reel.recentParticipants objectAtIndex:3] avatarURL];
        [cell.participantFourImageView setBackgroundColor:[UIColor lightGrayColor]];
        [cell.participantFourImageView setImageWithURL:[NSURL URLWithString:imageFourURLString]];
    }
    if ([reel.recentParticipants count] > 4) {
        NSString *imageFiveURLString = [(SBUser *)[reel.recentParticipants objectAtIndex:4] avatarURL];
        [cell.participantFiveImageView setBackgroundColor:[UIColor lightGrayColor]];
        [cell.participantFiveImageView setImageWithURL:[NSURL URLWithString:imageFiveURLString]];
    }
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
