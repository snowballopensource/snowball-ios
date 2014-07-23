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

@property (nonatomic) BOOL showsNewClipIndicator;

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
    
    BOOL hasNewClip = !([reel.updatedAt compare:reel.lastClip.createdAt] == NSOrderedDescending);
    [self setShowsNewClipIndicator:hasNewClip];
    
    [self setState:state animated:NO];
}

@end
