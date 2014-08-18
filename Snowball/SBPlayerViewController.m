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
@property (nonatomic, weak) IBOutlet UIImageView *userImageView;

@end

@implementation SBPlayerViewController

#pragma mark - UIViewController

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
    AVQueuePlayer *player = (AVQueuePlayer *)self.playerView.player;
    [player removeAllItems];
    [super viewWillDisappear:animated];
}

#pragma mark - Video Player

- (void)playReel {
    NSPredicate *predicate;
    if (self.reel.lastWatchedClip.createdAt) {
        predicate = [NSPredicate predicateWithFormat:@"remoteID != nil && reel == %@ && videoURL != nil && createdAt >= %@", self.reel, self.reel.lastWatchedClip.createdAt];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"remoteID != nil && reel == %@ && videoURL != nil", self.reel];
    }
    NSFetchRequest *fetchRequest = [SBClip MR_requestAllSortedBy:@"createdAt" ascending:YES withPredicate:predicate];
    [self setClips:[SBClip MR_executeFetchRequest:fetchRequest]];
    [self setCurrentClip:[self.clips firstObject]];
    AVQueuePlayer *player = [[AVQueuePlayer alloc] initWithItems:[self createPlayerItems]];
    [self.playerView setPlayer:player];
    if (self.clips.count == 1) {
        // This prevents it from tring to advance to nothing so that it freezes on last frame
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
    [self.playerView.player play];
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

#pragma mark - Private

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
        if (player.rate == 0 && CMTimeGetSeconds(player.currentItem.currentTime) != CMTimeGetSeconds(player.currentItem.duration)) {
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
    [self.userName setText:self.currentClip.user.username];
    [self.userImageView setImageWithURL:[NSURL URLWithString:self.currentClip.user.avatarURL]
                       placeholderImage:[SBUserImageView placeholderImageWithInitials:[self.currentClip.user.name initials] withSize:self.userImageView.frame.size]];
}

#pragma mark - Setters / Getters

- (void)setCurrentClip:(SBClip *)currentClip {
    [self updateClipUIForClip:currentClip];
    _currentClip = currentClip;
}

@end
