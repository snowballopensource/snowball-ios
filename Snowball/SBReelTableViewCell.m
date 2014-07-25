//
//  SBReelTableViewCell.m
//  Snowball
//
//  Created by James Martinez on 5/13/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBClip.h"
#import "SBReel.h"
#import "SBReelTableViewCell.h"
#import "SBUser.h"
#import "SBUserImageView.h"

@interface SBReelTableViewCell ()

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *participantOneImageView;
@property (nonatomic, weak) IBOutlet UIImageView *participantTwoImageView;
@property (nonatomic, weak) IBOutlet UIImageView *participantThreeImageView;
@property (nonatomic, weak) IBOutlet UIImageView *participantFourImageView;
@property (nonatomic, weak) IBOutlet UIImageView *participantFiveImageView;

@property (nonatomic, weak) IBOutlet UIImageView *disclosureIndicator;
@property (nonatomic, weak) IBOutlet UIImageView *hasNewClipIndicator;
@property (nonatomic, weak) IBOutlet UIImageView *addClipIndicator;
@property (nonatomic) BOOL showsDisclosureIndicator;
@property (nonatomic) BOOL showsHasNewClipIndicator;
@property (nonatomic) BOOL showsAddClipIndicator;

@property (nonatomic) SBReelTableViewCellState state;

@end

@implementation SBReelTableViewCell

#pragma mark - SBTableViewCell

- (void)configureForObject:(id)object {
    [self configureForObject:object state:SBReelTableViewCellStateNormal];
}

- (void)configureForObject:(id)object state:(SBReelTableViewCellState)state {
    SBReel *reel = (SBReel *)object;

    [self.nameLabel setText:reel.name];
    [self.participantOneImageView setImage:nil];
    [self.participantTwoImageView setImage:nil];
    [self.participantThreeImageView setImage:nil];
    [self.participantFourImageView setImage:nil];
    [self.participantFiveImageView setImage:nil];
    
    if ([reel.recentParticipants count] > 0) {
        SBUser *user = (SBUser *)[reel.recentParticipants firstObject];
        NSString *imageOneURLString = [user avatarURL];
        [self.participantOneImageView setImageWithURL:[NSURL URLWithString:imageOneURLString]
                                     placeholderImage:[SBUserImageView placeholderImageWithInitials:[user.name initials] withSize:self.participantOneImageView.frame.size]];
    }
    if ([reel.recentParticipants count] > 1) {
        SBUser *user = (SBUser *)[reel.recentParticipants objectAtIndex:1];
        NSString *imageTwoURLString = [user avatarURL];
        [self.participantTwoImageView setImageWithURL:[NSURL URLWithString:imageTwoURLString]
                                     placeholderImage:[SBUserImageView placeholderImageWithInitials:[user.name initials] withSize:self.participantTwoImageView.frame.size]];
    }
    if ([reel.recentParticipants count] > 2) {
        SBUser *user = (SBUser *)[reel.recentParticipants objectAtIndex:2];
        NSString *imageThreeURLString = [user avatarURL];
        [self.participantThreeImageView setImageWithURL:[NSURL URLWithString:imageThreeURLString]
                                       placeholderImage:[SBUserImageView placeholderImageWithInitials:[user.name initials] withSize:self.participantThreeImageView.frame.size]];
    }
    if ([reel.recentParticipants count] > 3) {
        SBUser *user = (SBUser *)[reel.recentParticipants objectAtIndex:3];
        NSString *imageFourURLString = [user avatarURL];
        [self.participantFourImageView setImageWithURL:[NSURL URLWithString:imageFourURLString]
                                      placeholderImage:[SBUserImageView placeholderImageWithInitials:[user.name initials] withSize:self.participantFourImageView.frame.size]];
    }
    if ([reel.recentParticipants count] > 4) {
        SBUser *user = (SBUser *)[reel.recentParticipants objectAtIndex:4];
        NSString *imageFiveURLString = [user avatarURL];
        [self.participantFiveImageView setImageWithURL:[NSURL URLWithString:imageFiveURLString]
                                      placeholderImage:[SBUserImageView placeholderImageWithInitials:[user.name initials] withSize:self.participantFiveImageView.frame.size]];
    }

    if (state == SBReelTableViewCellStateNormal) {
        // If the state is normal, we figure out if it does indeed have a new clip.
        BOOL hasNewClip = !([reel.updatedAt compare:reel.lastClip.createdAt] == NSOrderedDescending);
        if (hasNewClip) {
            [self setState:SBReelTableViewCellStateHasNewClip];
        } else {
            [self setState:SBReelTableViewCellStateNormal];
        }
    } else {
        [self setState:state];
    }
}

#pragma mark - State

- (void)setState:(SBReelTableViewCellState)state {
    [self setState:state animated:NO];
}

- (void)setState:(SBReelTableViewCellState)state animated:(BOOL)animated {
    _state = state;

    [self positionSubviewsForState:state animated:animated];
}

- (void)positionSubviewsForState:(SBReelTableViewCellState)state animated:(BOOL)animated {
    const CGFloat animationDuration = 0.25;
    switch (state) {
        case SBReelTableViewCellStateHasNewClip: {
            void(^positionSubviews)() = ^{
                [self setShowsAddClipIndicator:NO];
                [self setShowsDisclosureIndicator:NO];
                [self setShowsHasNewClipIndicator:YES];
            };
            if (animated) {
                [UIView animateWithDuration:animationDuration
                                 animations:^{
                                     positionSubviews();
                                 }];
            } else {
                positionSubviews();
            }
        }
            break;
        case SBReelTableViewCellStatePendingUpload: {
            void(^positionSubviews)() = ^{
                [self setShowsAddClipIndicator:YES];
                [self setShowsDisclosureIndicator:NO];
                [self setShowsHasNewClipIndicator:NO];
            };
            if (animated) {
                [UIView animateWithDuration:animationDuration
                                 animations:^{
                                     positionSubviews();
                                 }];
            } else {
                positionSubviews();
            }
        }
            break;
        default: { // SBReelTableViewCellStateNormal
            void(^positionSubviews)() = ^{
                [self setShowsAddClipIndicator:NO];
                [self setShowsDisclosureIndicator:YES];
                [self setShowsHasNewClipIndicator:NO];
            };
            if (animated) {
                [UIView animateWithDuration:animationDuration
                                 animations:^{
                                     positionSubviews();
                                 }];
            } else {
                positionSubviews();
            }
        }
            break;
    }
}

#pragma mark - Hiding/Showing Indicators

- (void)setShowsAddClipIndicator:(BOOL)showsAddClipIndicator {
    static CGFloat defaultAddClipIndicatorCenterX = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultAddClipIndicatorCenterX = self.addClipIndicator.center.x;
    });

    CGFloat newCenterX = (showsAddClipIndicator) ? defaultAddClipIndicatorCenterX : defaultAddClipIndicatorCenterX + 100;
    [self.addClipIndicator setCenter:CGPointMake(newCenterX, self.addClipIndicator.center.y)];

    _showsAddClipIndicator = showsAddClipIndicator;
}

- (void)setShowsDisclosureIndicator:(BOOL)showsDisclosureIndicator {
    static CGFloat defaultDisclosureIndicatorCenterX = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultDisclosureIndicatorCenterX = self.disclosureIndicator.center.x;
    });

    CGFloat newCenterX = (showsDisclosureIndicator) ? defaultDisclosureIndicatorCenterX : defaultDisclosureIndicatorCenterX + 100;
    [self.disclosureIndicator setCenter:CGPointMake(newCenterX, self.disclosureIndicator.center.y)];

    _showsDisclosureIndicator = showsDisclosureIndicator;
}

- (void)setShowsHasNewClipIndicator:(BOOL)showsHasNewClipIndicator {
    static CGFloat defaultHasNewClipIndicatorCenterX = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultHasNewClipIndicatorCenterX = self.hasNewClipIndicator.center.x;
    });

    CGFloat newCenterX = (showsHasNewClipIndicator) ? defaultHasNewClipIndicatorCenterX : defaultHasNewClipIndicatorCenterX + 100;
    [self.hasNewClipIndicator setCenter:CGPointMake(newCenterX, self.hasNewClipIndicator.center.y)];

    _showsHasNewClipIndicator = showsHasNewClipIndicator;
}

@end
