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

@property (nonatomic) BOOL showsDisclosureIndicator;
@property (nonatomic, weak) IBOutlet UIImageView *disclosureIndicator;

@property (nonatomic) BOOL showsHasNewClipIndicatonGroup;
@property (nonatomic, weak) IBOutlet UIImageView *hasNewClipIndicator;
@property (nonatomic, weak) IBOutlet UIImageView *unwatchedClipIcon;
@property (nonatomic, weak) IBOutlet UILabel *unwatchedClipTimestamp;
@property (nonatomic, weak) IBOutlet UIImageView *unwatchedClipThumbnail;

@property (nonatomic) BOOL showsAddClipIndicator;
@property (nonatomic, weak) IBOutlet UIImageView *addClipIndicator;

@property (nonatomic) BOOL showsUploadingIndicator;
@property (nonatomic, weak) IBOutlet UIView *uploadingIndicator;
@property (nonatomic, strong) UIActivityIndicatorView *uploadingIndicatorSpinner;

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
    [self.uploadingIndicator setBackgroundColor:tintColor];

    [self.unwatchedClipTimestamp setFont:[UIFont fontWithName:[UIFont snowballFontNameMedium] size:self.unwatchedClipTimestamp.font.pointSize]];
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

    [self.unwatchedClipTimestamp setText:[reel.lastClipCreatedAt shortTimeAgoString]];

    [self.unwatchedClipThumbnail setImageWithURL:[NSURL URLWithString:reel.lastClipThumbnailURL]];

    [self setState:state forReel:reel animated:NO];
}

#pragma mark - State

- (void)setState:(SBReelTableViewCellState)state {
    NSAssert(false, @"Use -setState:forReel:animated instead of -setState");
}

- (void)setState:(SBReelTableViewCellState)state forReel:(SBReel *)reel animated:(BOOL)animated {
    if (reel.hasNewClip && state == SBReelTableViewCellStateNormal) {
        state = SBReelTableViewCellStateHasNewClip;
    }
    if (reel.hasPendingUpload && (state == SBReelTableViewCellStateNormal || state == SBReelTableViewCellStateHasNewClip)) {
        state = SBReelTableViewCellStateUploading;
    }
    if (state == SBReelTableViewCellStateHasNewClip) {
        [self.unwatchedClipThumbnail setImageWithURL:[NSURL URLWithString:reel.lastClipThumbnailURL]];
    }
    _state = state;

    [self positionSubviewsForState:state animated:animated];
}

- (void)positionSubviewsForState:(SBReelTableViewCellState)state animated:(BOOL)animated {
    const CGFloat animationDuration = 0.25;
    void(^positionSubviews)() = nil;
    switch (state) {
        case SBReelTableViewCellStateHasNewClip: {
            positionSubviews = ^{
                [self setShowsAddClipIndicator:NO];
                [self setShowsDisclosureIndicator:NO];
                [self setShowsHasNewClipIndicatonGroup:YES];
                [self setShowsUploadingIndicator:NO];
            };
        }
            break;
        case SBReelTableViewCellStateAddClip: {
            positionSubviews = ^{
                [self setShowsAddClipIndicator:YES];
                [self setShowsDisclosureIndicator:NO];
                [self setShowsHasNewClipIndicatonGroup:NO];
                [self setShowsUploadingIndicator:NO];
            };
        }
            break;
        case SBReelTableViewCellStateUploading: {
            positionSubviews = ^{
                [self setShowsAddClipIndicator:NO];
                [self setShowsDisclosureIndicator:NO];
                [self setShowsHasNewClipIndicatonGroup:NO];
                [self setShowsUploadingIndicator:YES];
            };
        }
            break;
        default: { // SBReelTableViewCellStateNormal
            positionSubviews = ^{
                [self setShowsAddClipIndicator:NO];
                [self setShowsDisclosureIndicator:YES];
                [self setShowsHasNewClipIndicatonGroup:NO];
                [self setShowsUploadingIndicator:NO];
            };
        }
            break;
    }
    if (animated) {
        [UIView animateWithDuration:animationDuration
                         animations:^{
                             positionSubviews();
                         }];
    } else {
        positionSubviews();
    }
}

#pragma mark - Hiding/Showing Indicators

- (void)setShowsAddClipIndicator:(BOOL)showsAddClipIndicator {
    static CGFloat defaultAddClipIndicatorCenterX = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultAddClipIndicatorCenterX = self.addClipIndicator.center.x;
    });

    CGFloat newCenterX = (showsAddClipIndicator) ? defaultAddClipIndicatorCenterX : defaultAddClipIndicatorCenterX + 150;
    [self.addClipIndicator setCenter:CGPointMake(newCenterX, self.addClipIndicator.center.y)];

    _showsAddClipIndicator = showsAddClipIndicator;
}

- (void)setShowsDisclosureIndicator:(BOOL)showsDisclosureIndicator {
    static CGFloat defaultDisclosureIndicatorCenterX = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultDisclosureIndicatorCenterX = self.disclosureIndicator.center.x;
    });

    CGFloat newCenterX = (showsDisclosureIndicator) ? defaultDisclosureIndicatorCenterX : defaultDisclosureIndicatorCenterX + 150;
    [self.disclosureIndicator setCenter:CGPointMake(newCenterX, self.disclosureIndicator.center.y)];

    _showsDisclosureIndicator = showsDisclosureIndicator;
}

- (void)setShowsHasNewClipIndicatonGroup:(BOOL)showsHasNewClipIndicatonGroup {
    static CGFloat defaultHasNewClipIndicatorCenterX = 0;
    static CGFloat defaultUnwatchedClipIconCenterX = 0;
    static CGFloat defaultUnwatchedClipTimestampCenterX = 0;
    static CGFloat defaultUnwatchedClipThumbnailCenterX = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultHasNewClipIndicatorCenterX = self.hasNewClipIndicator.center.x;
        defaultUnwatchedClipIconCenterX = self.unwatchedClipIcon.center.x;
        defaultUnwatchedClipTimestampCenterX = self.unwatchedClipTimestamp.center.x;
        defaultUnwatchedClipThumbnailCenterX = self.unwatchedClipThumbnail.center.x;
    });

    CGFloat newHasNewClipIndicatorCenterX = (showsHasNewClipIndicatonGroup) ? defaultHasNewClipIndicatorCenterX : defaultHasNewClipIndicatorCenterX + 150;
    [self.hasNewClipIndicator setCenter:CGPointMake(newHasNewClipIndicatorCenterX, self.hasNewClipIndicator.center.y)];
    CGFloat newUnwatchedClipIconCenterX = (showsHasNewClipIndicatonGroup) ? defaultUnwatchedClipIconCenterX : defaultUnwatchedClipIconCenterX + 150;
    [self.unwatchedClipIcon setCenter:CGPointMake(newUnwatchedClipIconCenterX, self.unwatchedClipIcon.center.y)];
    CGFloat newUnwatchedClipTimestampCenterX = (showsHasNewClipIndicatonGroup) ? defaultUnwatchedClipTimestampCenterX : defaultUnwatchedClipTimestampCenterX + 150;
    [self.unwatchedClipTimestamp setCenter:CGPointMake(newUnwatchedClipTimestampCenterX, self.unwatchedClipTimestamp.center.y)];
    CGFloat newUnwatchedClipThumbnailCenterX = (showsHasNewClipIndicatonGroup) ? defaultUnwatchedClipThumbnailCenterX : defaultUnwatchedClipThumbnailCenterX + 150;
    [self.unwatchedClipThumbnail setCenter:CGPointMake(newUnwatchedClipThumbnailCenterX, self.unwatchedClipThumbnail.center.y)];

    _showsHasNewClipIndicatonGroup = showsHasNewClipIndicatonGroup;
}

- (void)setShowsUploadingIndicator:(BOOL)showsUploadingIndicator {
    static CGFloat defaultUploadingIndicatorCenterX = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultUploadingIndicatorCenterX = self.uploadingIndicator.center.x;
    });

    CGFloat newCenterX = 0;
    if (showsUploadingIndicator) {
        unless (self.uploadingIndicatorSpinner) {
            self.uploadingIndicatorSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            [self.uploadingIndicatorSpinner setFrame:self.uploadingIndicator.bounds];
            [self.uploadingIndicator addSubview:self.uploadingIndicatorSpinner];
        }
        [self.uploadingIndicatorSpinner startAnimating];
        newCenterX = defaultUploadingIndicatorCenterX;
    } else {
        [self.uploadingIndicatorSpinner stopAnimating];
        newCenterX = defaultUploadingIndicatorCenterX + 150;
    }
    [self.uploadingIndicator setCenter:CGPointMake(newCenterX, self.uploadingIndicator.center.y)];

    _showsUploadingIndicator = showsUploadingIndicator;
}

@end
