//
//  SBReelViewController.m
//  Snowball
//
//  Created by James Martinez on 5/7/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBClip.h"
#import "SBPlayerView.h"
#import "SBReelViewController.h"

@interface SBReelViewController ()

@property (weak, nonatomic) IBOutlet SBPlayerView *playerView;

@end

@implementation SBReelViewController

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [SBClip getClipsWithSuccess:^{
        [self playReel];
    } failure:^(NSError *error) {
    }];
}

#pragma mark - Video Player

- (void)playReel {
    NSArray *clips = [SBClip MR_findAll];
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

@end
