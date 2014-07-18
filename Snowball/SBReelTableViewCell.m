//
//  SBReelTableViewCell.m
//  Snowball
//
//  Created by James Martinez on 5/13/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBReelTableViewCell.h"

@interface SBReelTableViewCell ()

@property (nonatomic, weak) IBOutlet UIImageView *disclosureIndicator;
@property (nonatomic, weak) IBOutlet UIImageView *hasNewClipIndicator;
@property (nonatomic, weak) IBOutlet UIImageView *addClipIndicator;

@property (nonatomic) SBReelTableViewCellState state;

@end

@implementation SBReelTableViewCell

- (void)setShowsNewClipIndicator:(BOOL)showsNewClipIndicator {
    [self.hasNewClipIndicator setHidden:!showsNewClipIndicator];
    [self.disclosureIndicator setHidden:showsNewClipIndicator];
    _showsNewClipIndicator = showsNewClipIndicator;
}

// FOCUS ON:
// disclosure
// addClip

- (void)setState:(SBReelTableViewCellState)state animated:(BOOL)animated {
    static CGFloat defaultDisclosureIndicatorCenterX = 0;
    static CGFloat defaultHasNewClipIndicatorCenterX = 0;
    static CGFloat defaultAddClipIndicatorCenterX = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultDisclosureIndicatorCenterX = self.disclosureIndicator.center.x;
        defaultHasNewClipIndicatorCenterX = self.hasNewClipIndicator.center.x;
        defaultAddClipIndicatorCenterX = self.addClipIndicator.center.x;
    });
    
    CGFloat animationDuration = 0.25;
    switch (state) {
        case SBReelTableViewCellStatePendingUpload: {
            [self.addClipIndicator setHidden:NO];
            if (animated) {
                [UIView animateWithDuration:animationDuration
                                 animations:^{
                                     if (self.disclosureIndicator.center.x == defaultDisclosureIndicatorCenterX) {
                                         [self.disclosureIndicator setCenter:CGPointMake(defaultDisclosureIndicatorCenterX+100, self.disclosureIndicator.center.y)];
                                     }
                                     if (self.hasNewClipIndicator.center.x == defaultHasNewClipIndicatorCenterX) {
                                         [self.hasNewClipIndicator setCenter:CGPointMake(defaultHasNewClipIndicatorCenterX+100, self.hasNewClipIndicator.center.y)];
                                     }
                                     if (self.addClipIndicator.center.x == defaultAddClipIndicatorCenterX) {
                                         [self.addClipIndicator setCenter:CGPointMake(defaultAddClipIndicatorCenterX-100, self.addClipIndicator.center.y)];
                                     }
                                 }];
            } else {
                [self.disclosureIndicator setHidden:YES];
                [self.hasNewClipIndicator setHidden:YES];
            }
        }
            break;
        default: {
            if (animated) {
                [UIView animateWithDuration:animationDuration
                                 animations:^{
                                     unless (self.disclosureIndicator.center.x == defaultDisclosureIndicatorCenterX) {
                                         [self.disclosureIndicator setCenter:CGPointMake(defaultDisclosureIndicatorCenterX, self.disclosureIndicator.center.y)];
                                     }
                                     unless (self.hasNewClipIndicator.center.x == defaultHasNewClipIndicatorCenterX) {
                                         [self.hasNewClipIndicator setCenter:CGPointMake(defaultHasNewClipIndicatorCenterX, self.hasNewClipIndicator.center.y)];
                                     }
                                     unless (self.addClipIndicator.center.x == defaultAddClipIndicatorCenterX) {
                                         [self.addClipIndicator setCenter:CGPointMake(defaultAddClipIndicatorCenterX, self.addClipIndicator.center.y)];
                                     }
                                 } completion:^(BOOL finished) {
                                     [self.addClipIndicator setHidden:YES];
                                 }];
            } else {
                [self.addClipIndicator setHidden:YES];
                [self setShowsNewClipIndicator:_showsNewClipIndicator];
            }
        }
            break;
    }
    _state = state;
}

@end
