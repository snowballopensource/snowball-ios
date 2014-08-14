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
#import "SBNavigationController.h"
#import "SBPlayerView.h"
#import "SBReel.h"
#import "SBReelClipsViewController.h"
#import "SBReelsViewController.h"
#import "SBReelTableViewCell.h"
#import "SBSessionManager.h"
#import "SBUser.h"
#import "SBUserImageView.h"

typedef NS_ENUM(NSInteger, SBReelsViewControllerState) {
    SBReelsViewControllerStateNormal,
    SBReelsViewControllerStateAddClip,
    SBReelsViewControllerStatePlaying
};

@interface SBReelsViewController ()

@property (nonatomic, readonly) SBReelsViewControllerState state;
@property (nonatomic, strong) NSURL *recordingURL;

@property (nonatomic, weak) IBOutlet SBPlayerView *playerView;
@property (nonatomic, weak) IBOutlet UIView *createNewSnowballView;

@end

@implementation SBReelsViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SBReelTableViewCell registerNibToTableView:self.tableView];
    
    [self setEntityClass:[SBReel class]];
    [self setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastClipCreatedAt" ascending:NO]]];

    [self setState:SBReelsViewControllerStateNormal animated:NO];

    // TODO: remove this
    [self.createNewSnowballView.subviews each:^(id object) {
        if ([object isKindOfClass:[UIImageView class]]) {
            [object setImageTintColor:[UIColor whiteColor]];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self setState:SBReelsViewControllerStateNormal animated:animated];
    [self.playerView.player pause];
    [super viewWillDisappear:animated];
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
            [self setState:SBReelsViewControllerStateAddClip animated:YES];
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
    SBReelTableViewCellState cellState = [self cellStateForCellAtIndexPath:indexPath];
    [cell configureForObject:reel state:cellState];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (self.state) {
        case SBReelsViewControllerStateAddClip: {
            // This is semi duplicated code since clips are uploaded in three places.
            SBClip *clip = [SBClip MR_createEntity];
            SBReel *reel = [self.fetchedResultsController objectAtIndexPath:indexPath];
            [clip setReel:reel];
            NSData *data = [NSData dataWithContentsOfURL:self.recordingURL];
            [clip setVideoToSubmit:data];
            [reel save];
            [clip setCreatedAt:[NSDate date]];
            [clip save];
            [SBLongRunningTaskManager addBlockToQueue:^{
                [clip create];
            }];
            [self setState:SBReelsViewControllerStateNormal animated:YES];
        }
            break;
        default:
            [self performSegueWithIdentifier:[SBReelClipsViewController identifier] sender:self];
            break;
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - SBManagedTableViewController

- (void)getRemoteObjects {
    [SBReel getHomeFeedReelsOnPage:self.currentPage
                           success:^(BOOL canLoadMore){
                               [self setIsLoading:!canLoadMore];
                               [self.refreshControl endRefreshing];
                               [self setFetchedResultsController:nil];
                           } failure:^(NSError *error) {
                               [self.refreshControl endRefreshing];
                           }];
}

#pragma mark - Setters / Getters

- (void)setState:(SBReelsViewControllerState)state animated:(BOOL)animated {
    switch (state) {
        case SBReelsViewControllerStateNormal: {
            [self hideCameraPreview];
            [self hideNewSnowballView];
        }
            break;
        case SBReelsViewControllerStateAddClip: {
            [self showCameraPreview];
            [self showNewSnowballView];
        }
            break;
        case SBReelsViewControllerStatePlaying: {
            NSAssert(false, @"TODO");
            // TODO: show player vc
        }
            break;
    }

    _state = state;

    for (SBReelTableViewCell *cell in [self.tableView visibleCells]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        SBReelTableViewCellState cellState = [self cellStateForCellAtIndexPath:indexPath];
        [cell setState:cellState animated:animated];
    }
}

#pragma mark - View Actions

// TODO: refactor to -cancelNewClipCreation
- (IBAction)hideCameraPreview:(id)sender {
    [self setState:SBReelsViewControllerStateNormal animated:YES];
}

- (IBAction)switchToPeopleStoryboard:(id)sender {
    [(SBNavigationController *)self.navigationController switchToStoryboardWithName:@"People"];
}

#pragma mark - Private Actions

- (SBReelTableViewCellState)cellStateForCellAtIndexPath:(NSIndexPath *)indexPath {
    SBReel *reel = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (self.state == SBReelsViewControllerStateAddClip) {
        return SBReelTableViewCellStateAddClip;
    }
    if (self.state == SBReelsViewControllerStatePlaying) {
        //TODO: if reel is playing, return SBReelTableViewCellStatePlaying;
        // else continue....
    }
    if (self.state == SBReelsViewControllerStateNormal || self.state == SBReelsViewControllerStatePlaying) {
        if (reel.hasPendingUpload) {
            return SBReelTableViewCellStateUploading;
        } else if (reel.hasNewClip) {
            return SBReelTableViewCellStateHasNewClip;
        } else {
            return SBReelTableViewCellStateNormal;
        }
    }
    NSAssert(false, @"Handle translation of SBReelsViewControllerState to SBReelTableViewCellState");
    return SBReelTableViewCellStateNormal;
}

// Do not call any of these directly. They should be called via -setState

- (void)hideCameraPreview {
    [self.playerView setHidden:YES];
    [self.playerView setPlayer:nil];
}

- (void)showCameraPreview {
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

- (void)hideNewSnowballView {
    [UIView animateWithDuration:0.25
                     animations:^{
                         CGFloat newY = self.createNewSnowballView.frame.origin.y + self.createNewSnowballView.frame.size.height;
                         [self.createNewSnowballView setFrame:CGRectMake(self.createNewSnowballView.frame.origin.x, newY, self.createNewSnowballView.frame.size.width, self.createNewSnowballView.frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         [self.createNewSnowballView setHidden:YES];
                     }];
}

- (void)showNewSnowballView {
    [self.createNewSnowballView setHidden:NO];
    [UIView animateWithDuration:0.25
                     animations:^{
                         CGFloat newY = self.createNewSnowballView.frame.origin.y - self.createNewSnowballView.frame.size.height;
                         [self.createNewSnowballView setFrame:CGRectMake(self.createNewSnowballView.frame.origin.x, newY, self.createNewSnowballView.frame.size.width, self.createNewSnowballView.frame.size.height)];
                     }];
}

@end
