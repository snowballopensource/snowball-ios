//
//  SBReelsViewController.m
//  Snowball
//
//  Created by James Martinez on 5/13/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBCameraViewController.h"
#import "SBCreateReelViewController.h"
#import "SBClip.h"
#import "SBLongRunningTaskManager.h"
#import "SBPlayerView.h"
#import "SBReel.h"
#import "SBReelClipsViewController.h"
#import "SBReelsViewController.h"
#import "SBReelTableViewCell.h"
#import "SBSessionManager.h"
#import "SBUser.h"
#import "SBUserImageView.h"

@interface SBReelsViewController ()

@property (nonatomic) SBReelTableViewCellState cellState;
@property (nonatomic, strong) NSURL *recordingURL;

@property (nonatomic, weak) IBOutlet SBPlayerView *playerView;

@end

@implementation SBReelsViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SBReelTableViewCell registerNibToTableView:self.tableView];
    
    [self setEntityClass:[SBReel class]];
    [self setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO]]];
    [self setPredicate:[NSPredicate predicateWithFormat:@"homeFeedSession == %@", [SBSessionManager sessionDate]]];

    [self.playerView setHidden:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *destinationViewController = [segue destinationViewController];
    if ([destinationViewController isKindOfClass:[SBReelClipsViewController class]]) {
        SBReelClipsViewController *reelClipsViewController = [segue destinationViewController];
        SBReel *reel = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
        [reelClipsViewController setReel:reel];
    } else if ([destinationViewController isKindOfClass:[SBCameraViewController class]]) {
        [(SBCameraViewController *)destinationViewController setRecordingCompletionBlock:^(NSURL *fileURL) {
            [self setRecordingURL:fileURL];
            [self setCellState:SBReelTableViewCellStatePendingUpload];
        }];
    } else if ([destinationViewController isKindOfClass:[SBCreateReelViewController class]]) {
        [(SBCreateReelViewController *)destinationViewController setInitialRecordingURL:self.recordingURL];
    }
    [self setRecordingURL:nil];
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
    [cell.participantOneImageView setImage:nil];
    [cell.participantTwoImageView setImage:nil];
    [cell.participantThreeImageView setImage:nil];
    [cell.participantFourImageView setImage:nil];
    [cell.participantFiveImageView setImage:nil];

    if ([reel.recentParticipants count] > 0) {
        SBUser *user = (SBUser *)[reel.recentParticipants firstObject];
        NSString *imageOneURLString = [user avatarURL];
        [cell.participantOneImageView setImageWithURL:[NSURL URLWithString:imageOneURLString]
                                     placeholderImage:[SBUserImageView placeholderImageWithInitials:[user.name initials] withSize:cell.participantOneImageView.frame.size]];
    }
    if ([reel.recentParticipants count] > 1) {
        SBUser *user = (SBUser *)[reel.recentParticipants objectAtIndex:1];
        NSString *imageTwoURLString = [user avatarURL];
        [cell.participantTwoImageView setImageWithURL:[NSURL URLWithString:imageTwoURLString]
                                     placeholderImage:[SBUserImageView placeholderImageWithInitials:[user.name initials] withSize:cell.participantTwoImageView.frame.size]];
    }
    if ([reel.recentParticipants count] > 2) {
        SBUser *user = (SBUser *)[reel.recentParticipants objectAtIndex:2];
        NSString *imageThreeURLString = [user avatarURL];
        [cell.participantThreeImageView setImageWithURL:[NSURL URLWithString:imageThreeURLString]
                                       placeholderImage:[SBUserImageView placeholderImageWithInitials:[user.name initials] withSize:cell.participantThreeImageView.frame.size]];
    }
    if ([reel.recentParticipants count] > 3) {
        SBUser *user = (SBUser *)[reel.recentParticipants objectAtIndex:3];
        NSString *imageFourURLString = [user avatarURL];
        [cell.participantFourImageView setImageWithURL:[NSURL URLWithString:imageFourURLString]
                                      placeholderImage:[SBUserImageView placeholderImageWithInitials:[user.name initials] withSize:cell.participantFourImageView.frame.size]];
    }
    if ([reel.recentParticipants count] > 4) {
        SBUser *user = (SBUser *)[reel.recentParticipants objectAtIndex:4];
        NSString *imageFiveURLString = [user avatarURL];
        [cell.participantFiveImageView setImageWithURL:[NSURL URLWithString:imageFiveURLString]
                                      placeholderImage:[SBUserImageView placeholderImageWithInitials:[user.name initials] withSize:cell.participantFiveImageView.frame.size]];
    }

    BOOL hasNewClip = !([reel.updatedAt compare:reel.lastClip.createdAt] == NSOrderedDescending);
    [cell setShowsNewClipIndicator:hasNewClip];

    [cell setState:self.cellState animated:NO];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (self.cellState) {
        case SBReelTableViewCellStatePendingUpload: {
            // This is semi duplicated code since clips are uploaded in three places.
            SBClip *clip = [SBClip MR_createEntity];
            SBReel *reel = [self.fetchedResultsController objectAtIndexPath:indexPath];
            [clip setReel:reel];
            NSData *data = [NSData dataWithContentsOfURL:self.recordingURL];
            [clip setVideoToSubmit:data];
            [reel save];
            [clip save];
            [SBLongRunningTaskManager addBlockToQueue:^{
                [clip create];
            }];
            [self setCellState:SBReelTableViewCellStateNormal];
            [self.tableView reloadData];
        }
            break;
        default:
            [self performSegueWithIdentifier:[SBReelClipsViewController identifier] sender:self];
            break;
    }
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

#pragma mark - Setters / Getters

- (void)setCellState:(SBReelTableViewCellState)cellState {
    switch (cellState) {
        case SBReelTableViewCellStatePendingUpload:
            [self showCameraPreview];
            break;
        default:
            [self hideCameraPreview];
            break;
    }
    for (SBReelTableViewCell *cell in [self.tableView visibleCells]) {
        [cell setState:cellState animated:YES];
    }
    _cellState = cellState;
}

#pragma mark - View Actions

- (IBAction)hideCameraPreview:(id)sender {
    [self setCellState:SBReelTableViewCellStateNormal];
}

#pragma mark - Private Actions

- (void)hideCameraPreview {
    [self.playerView setHidden:YES];
    [self.playerView setPlayer:nil];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)showCameraPreview {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    AVPlayer *player = [[AVPlayer alloc] initWithURL:self.recordingURL];
    [self.playerView setPlayer:player];
    [(AVPlayerLayer *)self.playerView.layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.playerView setHidden:NO];
    [player play];
    [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:[player currentItem]
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [self.playerView.player seekToTime:kCMTimeZero];
                                                      [self.playerView.player play];
                                                  }];
}

@end
