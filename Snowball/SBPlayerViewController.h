//
//  SBPlayerViewController.h
//  Snowball
//
//  Created by James Martinez on 7/29/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBViewController.h"

@class SBReel;

@interface SBPlayerViewController : SBViewController

@property (nonatomic, strong) SBReel *reel;
@property (nonatomic, strong) NSURL *localVideoURL;

- (void)pause;
- (void)play;
- (void)stop;

@end
