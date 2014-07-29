//
//  SBReelClipsViewController.h
//  Snowball
//
//  Created by James Martinez on 5/7/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBViewController.h"

@class SBReel;

@interface SBReelClipsViewController : SBViewController

@property (nonatomic, strong) SBReel *reel;
@property (nonatomic, strong) NSString *reelID; // for deep linking
@property (nonatomic, strong) NSURL *localVideoURL;

@end
