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

@property (nonatomic, weak) IBOutlet UIButton *editReelButton;
@property (nonatomic, weak) IBOutlet UIButton *modalXButton;

@end

@implementation SBReelClipsViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([self isModal]) {
        [self.modalXButton setHidden:NO];
    } else {
        [self.modalXButton setHidden:YES];
    }

    [self setTintColor:self.reel.color];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
        id rootViewController = [(UINavigationController *)segue.destinationViewController viewControllers][0];
        if ([rootViewController isKindOfClass:[SBParticipantsViewController class]]) {
            SBParticipantsViewController *vc = rootViewController;
            [vc setReel:self.reel];
        }
    } else if ([segue.destinationViewController isKindOfClass:[SBPlayerViewController class]]) {
        SBPlayerViewController *vc = segue.destinationViewController;
        if (self.localVideoURL) {
            [vc setLocalVideoURL:self.localVideoURL];
        } else {
            // This ensures we have a reel before showing video player
            unless (self.reel) {
                SBReel *reel = [SBReel MR_findFirstByAttribute:@"remoteID" withValue:self.reelID];
                unless (reel) {
                    reel = [SBReel MR_createEntity];
                    [reel setRemoteID:self.reelID];
                    [reel save];
                }
                [self setReel:reel];
            }
            [vc setReel:self.reel];
        }
    }
}

#pragma mark - Private

- (void)setTintColor:(UIColor *)tintColor {
    [self.editReelButton setImageTintColor:tintColor];
}

@end
