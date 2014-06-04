//
//  SBCreateReelViewController.m
//  Snowball
//
//  Created by James Martinez on 6/4/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBCreateReelViewController.h"
#import "SBPlayerView.h"

@interface SBCreateReelViewController ()

@property (nonatomic, weak) IBOutlet SBPlayerView *playerView;
@property (nonatomic, weak) IBOutlet UIButton *finishButton;

@end

@implementation SBCreateReelViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    AVPlayer *player = [[AVPlayer alloc] initWithURL:self.initialRecordingURL];
    [self.playerView setPlayer:player];
    [player play];
}

- (IBAction)finish:(id)sender {

    // TODO: create reel with initial clip
}

@end
