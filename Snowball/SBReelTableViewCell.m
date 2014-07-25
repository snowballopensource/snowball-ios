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
@property (nonatomic, weak) IBOutlet UILabel *recentParticipantsNamesLabel;

@property (nonatomic, weak) IBOutlet UIImageView *disclosureIndicator;
@property (nonatomic, weak) IBOutlet UIImageView *hasNewClipIndicator;
@property (nonatomic, weak) IBOutlet UIImageView *addClipIndicator;
@property (nonatomic) BOOL showsDisclosureIndicator;
@property (nonatomic) BOOL showsHasNewClipIndicator;
@property (nonatomic) BOOL showsAddClipIndicator;

@property (nonatomic) SBReelTableViewCellState state;

@end

@implementation SBReelTableViewCell

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];

    [self.recentParticipantsNamesLabel setTextColor:tintColor];
    [self.nameLabel setTextColor:tintColor];
    [self.disclosureIndicator setImageTintColor:tintColor];
    [self.hasNewClipIndicator setImageTintColor:tintColor];
    [self.addClipIndicator setImageTintColor:tintColor];
}

#pragma mark - SBTableViewCell

- (void)configureForObject:(id)object {
    [self configureForObject:object state:SBReelTableViewCellStateNormal];
}

- (void)configureForObject:(id)object state:(SBReelTableViewCellState)state {
    SBReel *reel = (SBReel *)object;

    [self.recentParticipantsNamesLabel setText:reel.recentParticipantsNames];
    [self.nameLabel setFont:[UIFont fontWithName:[UIFont snowballFontNameMedium] size:24]];
    if (reel.name) {
        [self.nameLabel setText:reel.name];
    } else {
        [self.nameLabel setText:nil];
    }
    [self.nameLabel setFont:[UIFont fontWithName:[UIFont snowballFontNameMedium] size:12]];

    [self setTintColor:[UIColor randomColor]];

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
