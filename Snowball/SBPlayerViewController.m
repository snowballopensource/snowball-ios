//
//  SBPlayerViewController.m
//  Snowball
//
//  Created by James Martinez on 7/29/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBClip.h"
#import "SBPlayerView.h"
#import "SBPlayerViewController.h"
#import "SBReel.h"
#import "SBUser.h"
#import "SBUserImageView.h"

@interface SBPlayerViewController ()

@property (nonatomic, weak) IBOutlet SBPlayerView *playerView;

@property (nonatomic, strong) NSArray *clips;
@property (nonatomic, strong) SBClip *currentClip;

@property (nonatomic, weak) IBOutlet UILabel *userName;
@property (nonatomic, weak) IBOutlet SBUserImageView *userImageView;

@property (nonatomic) BOOL playing;

@end

@implementation SBPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.userName setText:@""];
}

#pragma mark - Public

- (void)pause {
    [self setPlaying:NO];
    [self.playerView.player pause];
}

- (void)play {
    [self setPlaying:YES];
    AVQueuePlayer *player = (AVQueuePlayer *)self.playerView.player;
    if ([player.items count] > 0) {
        [self resume];
    } else if (self.localVideoURL) {
        [self playLocalVideo];
    } else if (self.reel) {
        [self showSpinner];
        [SBClip getRecentClipsForReel:self.reel
                                since:self.reel.lastWatchedClip.createdAt
                              success:^(BOOL canLoadMore) {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [self playReel];
                                  });
                              }
                              failure:nil];
    }
}

- (void)stop {
    [self setPlaying:NO];
    AVQueuePlayer *player = (AVQueuePlayer *)self.playerView.player;
    [player removeAllItems];
    self.playerView.player = nil;
}

#pragma mark - Private

- (void)resume {
    [self.playerView.player play];
}

- (void)playReel {
    [self setClips:[self.reel playerClips]];
    [self setCurrentClip:[self.clips firstObject]];
    AVQueuePlayer *player = [[AVQueuePlayer alloc] initWithItems:[self createPlayerItems]];
    [self.playerView setPlayer:player];
    if (self.clips.count == 1) {
        // This prevents it from trying to advance to nothing so that it freezes on last frame
        [player setActionAtItemEnd:AVPlayerActionAtItemEndPause];
    } else {
        [player setActionAtItemEnd:AVPlayerActionAtItemEndAdvance];
    }
    
    [self setupPlayerIssueHandling];
    
    [player play];
}

- (void)playLocalVideo {
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:self.localVideoURL];
    AVQueuePlayer *player = [[AVQueuePlayer alloc] initWithItems:@[playerItem]];
    [self.playerView setPlayer:player];
    
    [player setActionAtItemEnd:AVPlayerActionAtItemEndPause];

    [self setupPlayerIssueHandling];
    
    [player play];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:[player currentItem]
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [self.playerView.player seekToTime:kCMTimeZero];
                                                      [self.playerView.player play];
                                                  }];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    NSUInteger currentClipIndex = [self.clips indexOfObject:self.currentClip];
    SBClip *previousClip = self.clips[currentClipIndex];
    [self.reel setLastWatchedClip:previousClip];
    [self.reel save];
    
    NSUInteger nextClipIndex = currentClipIndex+1;
    if (nextClipIndex < [self.clips count]) {
        SBClip *nextClip = self.clips[nextClipIndex];
        [self setCurrentClip:nextClip];
    }
    if (nextClipIndex == [self.clips count]-1) {
        // Last clip coming up next
        [self.playerView.player setActionAtItemEnd:AVPlayerActionAtItemEndPause];
    }
}

- (NSArray *)createPlayerItems {
    NSMutableArray *playerItems = [@[] mutableCopy];
    for (SBClip *clip in self.clips) {
        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:clip.videoURL]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:playerItem];
        [playerItems addObject:playerItem];
    }
    return [playerItems copy];
}

- (void)setupPlayerIssueHandling {
    AVQueuePlayer *player = (AVQueuePlayer *)self.playerView.player;
    
    // Handle player errors
    [player bk_addObserverForKeyPath:@"status" task:^(id target) {
        if (player.status == AVPlayerStatusFailed) {
            NSLog(@"Player Error: %@", player.error);
        }
    }];
    
    // Handle buffering during clip playback
    [player bk_addObserverForKeyPath:@"rate" task:^(id target) {
        if (player.rate == 1) {
            [self hideSpinner];
        }
        if (player.rate == 0 && CMTimeGetSeconds(player.currentItem.currentTime) != CMTimeGetSeconds(player.currentItem.duration) && self.playing) {
            [self showSpinner];
            [player.currentItem bk_addObserverForKeyPath:@"playbackLikelyToKeepUp" task:^(id target) {
                if (player.currentItem.playbackLikelyToKeepUp) {
                    [player play];
                }
            }];
        }
    }];
}

- (void)updateClipUIForClip:(SBClip *)clip {
    [self.userName setText:clip.user.username];
    [self.userImageView setImageWithUser:clip.user];
}

#pragma mark - Setters / Getters

- (void)setCurrentClip:(SBClip *)currentClip {
    [self updateClipUIForClip:currentClip];
    _currentClip = currentClip;
}

@end
