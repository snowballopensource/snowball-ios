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

@property (strong, nonatomic) SBReel *reel;

@property (nonatomic, strong) NSURL *localVideoURL;

@end
