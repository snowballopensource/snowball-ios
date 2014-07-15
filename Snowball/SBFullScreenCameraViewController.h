//
//  SBFullScreenCameraViewController.h
//  Snowball
//
//  Created by James Martinez on 6/10/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBViewController.h"

@class SBReel;

@interface SBFullScreenCameraViewController : SBViewController

@property (nonatomic, strong) SBReel *reel;
@property (nonatomic, copy) void(^recordingCompletionBlock)(NSURL *fileURL);

@end
