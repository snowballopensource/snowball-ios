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
        // [self playReel];
    } failure:^(NSError *error) {
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self playReel];
}

#pragma mark - Video Player

- (void)playReel {
    NSURL *videoURL = [NSURL URLWithString:@"http://techslides.com/demos/sample-videos/small.mp4"];
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:videoURL];
    NSURL *anotherVideoURL = [NSURL URLWithString:@"http://static.bouncingminds.com/ads/5secs/baileys_5sec.mp4"];
    AVPlayerItem *anotherPlayerItem = [[AVPlayerItem alloc] initWithURL:anotherVideoURL];
    AVPlayerItem *evenAnotherPlayerItem = [[AVPlayerItem alloc] initWithURL:videoURL];
    NSArray *items = @[playerItem, anotherPlayerItem, evenAnotherPlayerItem];
    AVQueuePlayer *player = [[AVQueuePlayer alloc] initWithItems:items];
    [self.playerView setPlayer:player];
    [player setActionAtItemEnd:AVPlayerActionAtItemEndAdvance];
    [player play];
}

@end
