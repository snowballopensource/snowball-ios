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

@interface SBPlayerViewController ()

@property (nonatomic, weak) IBOutlet SBPlayerView *playerView;

@property (nonatomic, strong) NSArray *clips;
@property (nonatomic) NSUInteger currentClipIndex;

@end

@implementation SBPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self showSpinner];
    [SBClip getRecentClipsForReel:self.reel
                            since:self.reel.lastWatchedClip.createdAt
                          success:^(BOOL canLoadMore) {
                              [self playReel];
                          }
                          failure:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.playerView.player pause];
    [super viewWillDisappear:animated];
}

#pragma mark - Video Player

- (void)playReel {
    NSPredicate *predicate;
    if (self.reel.lastWatchedClip.createdAt) {
        predicate = [NSPredicate predicateWithFormat:@"reel == %@ && createdAt >= %@", self.reel, self.reel.lastWatchedClip.createdAt];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"reel == %@", self.reel];
    }
    NSFetchRequest *fetchRequest = [SBClip MR_requestAllSortedBy:@"createdAt" ascending:YES withPredicate:predicate];
    [self setClips:[SBClip MR_executeFetchRequest:fetchRequest]];
    self.clipChangedBlock([self.clips firstObject]);
    AVQueuePlayer *player = [[AVQueuePlayer alloc] initWithItems:[self createPlayerItems]];
    [self.playerView setPlayer:player];
    if (self.clips.count == 1) {
        // This prevents it from tring to advance to nothing so that it freezes on last frame
        [player setActionAtItemEnd:AVPlayerActionAtItemEndPause];
    } else {
        [player setActionAtItemEnd:AVPlayerActionAtItemEndAdvance];
    }
    
    // Handle buffering during clip playback
    [player bk_addObserverForKeyPath:@"rate" task:^(id target) {
        if (player.rate == 1) {
            [self hideSpinner];
        }
        if (player.rate == 0 && CMTimeGetSeconds(player.currentItem.currentTime) != CMTimeGetSeconds(player.currentItem.duration)) {
            [self showSpinner];
            [player.currentItem bk_addObserverForKeyPath:@"playbackLikelyToKeepUp" task:^(id target) {
                if (player.currentItem.playbackLikelyToKeepUp) {
                    [player play];
                }
            }];
        }
    }];
    [player play];
}

- (void)playLocalVideo {
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:self.localVideoURL];
    AVQueuePlayer *player = [[AVQueuePlayer alloc] initWithItems:@[playerItem]];
    [self.playerView setPlayer:player];
    [self.playerView.player play];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    SBClip *previousClip = self.clips[self.currentClipIndex];
    [self.reel setLastWatchedClip:previousClip];
    [self.reel save];
    
    NSUInteger nextClipIndex = self.currentClipIndex+1;
    
    if (nextClipIndex < [self.clips count]) {
        SBClip *nextClip = self.clips[nextClipIndex];
        self.clipChangedBlock(nextClip);
    }
    if (nextClipIndex == [self.clips count]-1) {
        // Last clip coming up next
        [self.playerView.player setActionAtItemEnd:AVPlayerActionAtItemEndPause];
    }
    
    self.currentClipIndex ++;
}

- (NSArray *)createPlayerItems {
    NSMutableArray *playerItems = [@[] mutableCopy];
    for (SBClip *clip in self.clips) {
        if ([clip.videoURL length] > 0) {
            AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:clip.videoURL]];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(playerItemDidReachEnd:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:playerItem];
            [playerItems addObject:playerItem];
        }
    }
    return [playerItems copy];
}

@end
