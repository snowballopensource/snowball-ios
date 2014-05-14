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

#pragma mark - Video Player

- (void)playReel {
    // TODO: make this managed
    NSArray *clips = [self.reel.clips allObjects];
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
