//
//  SBReelClipsViewController.m
//  Snowball
//
//  Created by James Martinez on 5/7/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBClip.h"
#import "SBPlayerView.h"
#import "SBReel.h"
#import "SBReelClipsViewController.h"
#import "SBVideoPickerController.h"

@interface SBReelClipsViewController ()

@property (nonatomic, weak) IBOutlet SBPlayerView *playerView;

@end

@implementation SBReelClipsViewController // TODO: make this a managed controller somehow

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

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
                                         SBClip *clip = [SBClip MR_createEntity];
                                         [clip setReel:self.reel];
                                         [clip setVideoToSubmit:videoData];
                                         [clip save];
                                         [self playLocalVideoImmediately:videoLocalURL];
                                         [clip create];
                                         // [SBClip createClipInUploadManager:clip];
                                     }];
}

#pragma mark - Video Player

- (void)playReel {
    // TODO: make this managed
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"reel == %@", self.reel];
    NSFetchRequest *fetchRequest = [SBClip MR_requestAllSortedBy:@"createdAt" ascending:YES withPredicate:predicate];
    NSArray *clips = [SBClip MR_executeFetchRequest:fetchRequest];
    NSMutableArray *playerItems = [NSMutableArray new];
    for (SBClip *clip in clips) {
        if ([clip.videoURL length] > 0) {
            NSURL *videoURL = [NSURL URLWithString:clip.videoURL];
            AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:videoURL];
            [playerItems addObject:playerItem];
        }
    }
    AVQueuePlayer *player = [[AVQueuePlayer alloc] initWithItems:[playerItems copy]];
    [self.playerView setPlayer:player];
    [player setActionAtItemEnd:AVPlayerActionAtItemEndAdvance];
    [player play];
}

- (void)playLocalVideoImmediately:(NSURL *)videoLocalURL {
    [self.playerView.player removeAllItems];
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:videoLocalURL];
    [self.playerView.player replaceCurrentItemWithPlayerItem:playerItem];
}

@end
