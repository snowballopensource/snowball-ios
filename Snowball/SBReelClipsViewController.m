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
@property (nonatomic, copy) NSArray *clips;
@property (nonatomic, copy, readonly) NSArray *playerItems;

@end

@implementation SBReelClipsViewController // TODO: make this a managed controller somehow

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.userButton setTitle:@"" forState:UIControlStateNormal];
    
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"reel == %@", self.reel];
    NSFetchRequest *fetchRequest = [SBClip MR_requestAllSortedBy:@"createdAt" ascending:YES withPredicate:predicate];
    [self setClips:[SBClip MR_executeFetchRequest:fetchRequest]];
    [self setCurrentClip:[self.clips firstObject]];
    AVQueuePlayer *player = [[AVQueuePlayer alloc] initWithItems:self.playerItems];
    [player setActionAtItemEnd:AVPlayerActionAtItemEndAdvance];
    [player play];
    [self.playerView setPlayer:player];
}

- (void)playLocalVideoImmediately:(NSURL *)videoLocalURL {
    [(AVQueuePlayer *)self.playerView.player removeAllItems];
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:videoLocalURL];
    [self.playerView.player replaceCurrentItemWithPlayerItem:playerItem];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *currentPlayerItem = [notification object];
    NSUInteger nextPlayerItemIndex = [self.playerItems indexOfObject:currentPlayerItem]+1;
    if (nextPlayerItemIndex < [self.playerItems count]) {
        SBClip *nextClip = self.clips[nextPlayerItemIndex];
        [self setCurrentClip:nextClip];
    }
}

- (void)updateClipUI {
    [self.userButton setTitle:self.currentClip.user.username forState:UIControlStateNormal];
    [self.userImageView setImageWithURL:[NSURL URLWithString:self.currentClip.user.avatarURL]
                       placeholderImage:[SBUserImageView placeholderImageWithInitials:[self.currentClip.user.name initials] withSize:self.userImageView.frame.size]];
}

#pragma mark - Setters / Getters

- (void)setClips:(NSArray *)clips {
    _clips = [clips copy];
    NSMutableArray *playerItems = [NSMutableArray new];
    for (SBClip *clip in self.clips) {
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
    _playerItems = [playerItems copy];
}

- (void)setCurrentClip:(SBClip *)currentClip {
    _currentClip = currentClip;
    [self updateClipUI];
}

@end
