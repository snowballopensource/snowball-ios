//
//  SBReelClipsViewController.m
//  Snowball
//
//  Created by James Martinez on 5/7/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBCameraNavigationController.h"
#import "SBClip.h"
#import "SBFullScreenCameraViewController.h"
#import "SBParticipantsViewController.h"
#import "SBPlayerView.h"
#import "SBProfileViewController.h"
#import "SBReel.h"
#import "SBReelClipsViewController.h"
#import "SBUser.h"
#import "SBUserImageView.h"

@interface SBReelClipsViewController ()

@property (nonatomic, weak) IBOutlet SBPlayerView *playerView;
@property (nonatomic, weak) IBOutlet UIButton *userButton;
@property (nonatomic, weak) IBOutlet UIImageView *userImageView;

@property (nonatomic, strong) SBClip *currentClip;
@property (nonatomic, strong) NSDate *sinceDate;
@property (nonatomic, copy) NSArray *clips;
@property (nonatomic, copy, readonly) NSArray *playerItems;

@end

@implementation SBReelClipsViewController

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.userButton setTitle:@"" forState:UIControlStateNormal];
    
    if (self.localVideoURL) {
        [self playLocalVideoImmediately];
    } else {
        [self showSpinner];
        [self setSinceDate:self.reel.lastClip.createdAt];
        [SBClip getRecentClipsForReel:self.reel
                                since:self.sinceDate
                              success:^(BOOL canLoadMore) {
                                  [self hideSpinner];
                                  [self playReel];
                              }
                              failure:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.playerView.player pause];
    [super viewWillDisappear:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[SBCameraNavigationController class]]) {
        SBFullScreenCameraViewController *vc = (SBFullScreenCameraViewController *)[[(SBCameraNavigationController *)segue.destinationViewController viewControllers] firstObject];
        [vc setReel:self.reel];
    } else if ([segue.destinationViewController isKindOfClass:[SBProfileViewController class]]) {
        SBProfileViewController *vc = segue.destinationViewController;
        [vc setUser:self.currentClip.user];
    } else if ([segue.destinationViewController isKindOfClass:[SBParticipantsViewController class]]) {
        SBParticipantsViewController *vc = segue.destinationViewController;
        [vc setReel:self.reel];
    }
}

#pragma mark - Video Player

- (void)playReel {
    NSPredicate *predicate;
    if (self.sinceDate) {
        predicate = [NSPredicate predicateWithFormat:@"reel == %@ && createdAt >= %@", self.reel, self.sinceDate];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"reel == %@", self.reel];
    }
    NSFetchRequest *fetchRequest = [SBClip MR_requestAllSortedBy:@"createdAt" ascending:YES withPredicate:predicate];
    [self setClips:[SBClip MR_executeFetchRequest:fetchRequest]];
    [self setCurrentClip:[self.clips firstObject]];
    AVQueuePlayer *player = [[AVQueuePlayer alloc] initWithItems:self.playerItems];
    if (self.clips.count == 1) {
        // This prevents it from tring to advance to nothing so that it freezes on last frame
        [player setActionAtItemEnd:AVPlayerActionAtItemEndPause];
    } else {
        [player setActionAtItemEnd:AVPlayerActionAtItemEndAdvance];
    }
    [player play];
    [self.playerView setPlayer:player];
}

- (void)playLocalVideoImmediately {
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:self.localVideoURL];
    AVQueuePlayer *player = [[AVQueuePlayer alloc] initWithItems:@[playerItem]];
    [self.playerView setPlayer:player];
    [self.playerView.player play];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *currentPlayerItem = [notification object];
    NSUInteger nextPlayerItemIndex = [self.playerItems indexOfObject:currentPlayerItem]+1;
    if (nextPlayerItemIndex < [self.playerItems count]) {
        SBClip *nextClip = self.clips[nextPlayerItemIndex];
        [self setCurrentClip:nextClip];
    }
    if (nextPlayerItemIndex == [self.playerItems count]-1) {
        // Last clip coming up next
        [self.playerView.player setActionAtItemEnd:AVPlayerActionAtItemEndPause];
    }
}

- (void)updateClipUI {
    [self.userButton setTitle:self.currentClip.user.username forState:UIControlStateNormal];
    [self.userImageView setImageWithURL:[NSURL URLWithString:self.currentClip.user.avatarURL]
                       placeholderImage:[SBUserImageView placeholderImageWithInitials:[self.currentClip.user.name initials] withSize:self.userImageView.frame.size]];
}

#pragma mark - Setters / Getters

- (void)setClips:(NSArray *)clips {
    NSMutableArray *playerItems = [NSMutableArray new];
    for (SBClip *clip in clips) {
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
    _clips = [clips copy];
    _playerItems = [playerItems copy];
}

- (void)setCurrentClip:(SBClip *)currentClip {
    _currentClip = currentClip;
    [self updateClipUI];
}

@end
