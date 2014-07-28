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
@property (nonatomic, weak) IBOutlet UIView *createNewSnowballView;

@end

@implementation SBReelsViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SBReelTableViewCell registerNibToTableView:self.tableView];
    
    [self setEntityClass:[SBReel class]];
    [self setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastClipCreatedAt" ascending:NO]]];
    [self setPredicate:[NSPredicate predicateWithFormat:@"homeFeedSession == %@", [SBSessionManager sessionDate]]];
    
    [self.playerView setHidden:YES];
    [self.createNewSnowballView setHidden:YES];

    [self.createNewSnowballView.subviews each:^(id object) {
        if ([object isKindOfClass:[UIImageView class]]) {
            [object setImageTintColor:[UIColor whiteColor]];
        }
    }];
    
    // [self startCellStateDemo];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self setCellState:SBReelTableViewCellStateNormal];
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
    [cell configureForObject:reel state:self.cellState];
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
            [self showNewSnowballView];
            break;
        default:
            [self hideCameraPreview];
            [self hideNewSnowballView];
            break;
    }
    for (SBReelTableViewCell *cell in [self.tableView visibleCells]) {
        SBReel *reel = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
        [cell setState:cellState forReel:reel animated:YES];
    }
    _cellState = cellState;
}

#pragma mark - View Actions

// TODO: refactor to -cancelNewClipCreation
- (IBAction)hideCameraPreview:(id)sender {
    [self setCellState:SBReelTableViewCellStateNormal];
}

#pragma mark - Private Actions

// Do not call any of these directly. They should be called via -setCellState

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

#pragma mark - Testing

- (void)startCellStateDemo {
    [NSTimer bk_scheduledTimerWithTimeInterval:2.0
                                         block:^(NSTimer *timer) {
                                             if (self.cellState == SBReelTableViewCellStateNormal) {
                                                 [self setCellState:SBReelTableViewCellStatePendingUpload];
                                             } else {
                                                 [self setCellState:SBReelTableViewCellStateNormal];
                                             }
                                         }
                                       repeats:YES];
}

@end
