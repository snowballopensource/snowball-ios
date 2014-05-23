//
//  SBReelClipsViewController.m
//  Snowball
//
//  Created by James Martinez on 5/7/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBLongRunningTaskManager.h"
#import "SBClip.h"
#import "SBPlayerView.h"
#import "SBReel.h"
#import "SBReelClipsViewController.h"
#import "SBUser.h"
#import "SBVideoPickerController.h"

@interface SBReelClipsViewController ()

@property (nonatomic, weak) IBOutlet SBPlayerView *playerView;
@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *likesCountLabel;

@property (nonatomic, strong) SBClip *currentClip;
@property (nonatomic, copy) NSArray *clips;
@property (nonatomic, copy, readonly) NSArray *playerItems;

@end

@implementation SBReelClipsViewController // TODO: make this a managed controller somehow

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.userNameLabel setText:@""];
    [self.likesCountLabel setText:@""];

    // TODO: make this paginated
    [SBClip getRecentClipsForReel:self.reel
                             page:0
                          success:^(BOOL canLoadMore) {
                              [self playReel];
                          }
                          failure:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.playerView.player pause];
}

#pragma mark - View Actions

- (IBAction)takeVideo:(id)sender {
    [SBVideoPickerController launchCameraInView:self.view
                                         sender:self
                                     completion:^(NSData *videoData, NSURL *videoLocalURL) {
                                         [SBLongRunningTaskManager addBlockToQueue:^{
                                             SBClip *clip = [SBClip MR_createEntity];
                                             [clip setReel:[self.reel MR_inContext:clip.managedObjectContext]];
                                             [clip setVideoToSubmit:videoData];
                                             [clip save];
                                             [clip create];
                                         }];
                                         [self playLocalVideoImmediately:videoLocalURL];
                                     }];
}

- (IBAction)likeClip:(id)sender {
    if (self.currentClip.likedValue) {
        NSLog(@"Unliking...");
        [self.currentClip unlikeWithSuccess:^{
            NSLog(@"Unliked.");
        } failure:^(NSError *error) {
            NSLog(@"Failed Unliked.");
        }];
    }
    else {
        NSLog(@"Liking...");
        [self.currentClip likeWithSuccess:^{
            NSLog(@"Liked.");
        } failure:^(NSError *error) {
            NSLog(@"Failed Liked.");
        }];
    }
}

#pragma mark - Video Player

- (void)playReel {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"reel == %@", self.reel];
    NSFetchRequest *fetchRequest = [SBClip MR_requestAllSortedBy:@"createdAt" ascending:YES withPredicate:predicate];
    [self setClips:[SBClip MR_executeFetchRequest:fetchRequest]];
    [self setCurrentClip:[self.clips firstObject]];
    AVQueuePlayer *player = [[AVQueuePlayer alloc] initWithItems:self.playerItems];
    [player setActionAtItemEnd:AVPlayerActionAtItemEndAdvance];
    [player play];
    [self.playerView setPlayer:player];
}

- (void)playLocalVideoImmediately:(NSURL *)videoLocalURL {
    [self.playerView.player removeAllItems];
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:videoLocalURL];
    [self.playerView.player replaceCurrentItemWithPlayerItem:playerItem];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *currentPlayerItem = [notification object];
    NSUInteger nextPlayerItemIndex = [self.playerItems indexOfObject:currentPlayerItem];
    if (nextPlayerItemIndex < [self.playerItems count]) {
        SBClip *nextClip = self.clips[nextPlayerItemIndex];
        [self setCurrentClip:nextClip];
    }
}

- (void)setCurrentClip:(SBClip *)currentClip {
    _currentClip = currentClip;
    [self.userNameLabel setText:currentClip.user.username];
    [self.likesCountLabel setText:[NSString stringWithFormat:@"%@", currentClip.likesCount]];
}

#pragma mark - Setters / Getters

- (void)setClips:(NSArray *)clips {
    _clips = [clips copy];
    NSMutableArray *playerItems = [NSMutableArray new];
    for (SBClip *clip in self.clips) {
        if ([clip.videoURL length] > 0) {
            NSURL *videoURL = [NSURL URLWithString:clip.videoURL];
            AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:videoURL];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(playerItemDidReachEnd:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:playerItem];
            [playerItems addObject:playerItem];
        }
    }
    _playerItems = [playerItems copy];
}

@end
