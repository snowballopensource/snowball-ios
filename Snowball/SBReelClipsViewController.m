//
//  SBReelClipsViewController.m
//  Snowball
//
//  Created by James Martinez on 5/7/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBClip.h"
#import "SBParticipantsViewController.h"
#import "SBPlayerViewController.h"
#import "SBReel.h"
#import "SBReelClipsViewController.h"
#import "SBUser.h"
#import "SBUserImageView.h"

@interface SBReelClipsViewController ()

@property (nonatomic, weak) IBOutlet UIButton *userButton;
@property (nonatomic, weak) IBOutlet UIImageView *userImageView;

@property (nonatomic, weak) IBOutlet UIButton *modalXButton;

@property (nonatomic, strong) SBClip *currentClip;

@end

@implementation SBReelClipsViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    unless (self.reel) {
        self.reel = [SBReel MR_findFirstByAttribute:@"remoteID" withValue:self.reelID];
    }

    if ([self isModal]) {
        [self.modalXButton setHidden:NO];
    } else {
        [self.modalXButton setHidden:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.userButton setTitle:@"" forState:UIControlStateNormal];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[SBParticipantsViewController class]]) {
        SBParticipantsViewController *vc = segue.destinationViewController;
        [vc setReel:self.reel];
    } else if ([segue.destinationViewController isKindOfClass:[SBPlayerViewController class]]) {
        SBPlayerViewController *vc = segue.destinationViewController;
        [vc setClipChangedBlock:^(SBClip *newClip) {
            [self setCurrentClip:newClip];
            [self updateClipUI];
        }];
        if (self.localVideoURL) {
            [vc setLocalVideoURL:self.localVideoURL];
        } else {
            [vc setReel:self.reel];
        }
    }
}

#pragma mark - Video Player

- (void)updateClipUI {
    [self.userButton setTitle:self.currentClip.user.username forState:UIControlStateNormal];
    [self.userImageView setImageWithURL:[NSURL URLWithString:self.currentClip.user.avatarURL]
                       placeholderImage:[SBUserImageView placeholderImageWithInitials:[self.currentClip.user.name initials] withSize:self.userImageView.frame.size]];
}

@end
