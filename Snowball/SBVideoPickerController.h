//
//  SBVideoPickerController.h
//  Snowball
//
//  Created by James Martinez on 5/13/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBVideoPickerController : UIImagePickerController

+ (void)launchCameraInView:(UIView *)view sender:(id)sender completion:(void(^)(NSData *videoData, NSURL *videoLocalURL))completion;

@end
