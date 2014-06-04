//
//  SBVideoPickerViewController.h
//  Snowball
//
//  Created by James Martinez on 5/29/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBViewController.h"

@interface SBVideoPickerViewController : SBViewController

@property (nonatomic, copy) void(^videoCaptureCompleteBlock)(NSData *videoData);

@end
