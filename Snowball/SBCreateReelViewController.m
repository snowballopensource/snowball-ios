//
//  SBCreateReelViewController.m
//  Snowball
//
//  Created by James Martinez on 6/4/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBCreateReelViewController.h"
#import "SBClip.h"
#import "SBLongRunningTaskManager.h"
#import "SBPlayerView.h"
#import "SBReel.h"

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
    // This is semi duplicated code.
    SBClip *clip = [SBClip MR_createEntity];
    SBReel *reel = [SBReel MR_createEntity];
    [clip setReel:reel];
    NSData *data = [NSData dataWithContentsOfURL:self.initialRecordingURL];
    [clip setVideoToSubmit:data];
    [reel save];
    [clip save];
    [SBLongRunningTaskManager addBlockToQueue:^{
        [clip create];
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
