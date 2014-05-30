//
//  SBCameraNavigationBar.m
//  Snowball
//
//  Created by James Martinez on 5/19/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBCameraManager.h"
#import "SBCameraNavigationBar.h"

@implementation SBCameraNavigationBar

- (void)startCamera {
    GPUImageVideoCamera *videoCamera = [SBCameraManager sharedManager].videoCamera;
    GPUImageGaussianBlurFilter *filter = [GPUImageGaussianBlurFilter new];
    [filter setBlurPasses:1];
    [filter setBlurRadiusInPixels:4];
    
    [self setFillMode:kGPUImageFillModePreserveAspectRatioAndFill];
    
    // Video camera passes output to filter, and filter passes output to outputView
    [videoCamera removeAllTargets];
    [videoCamera addTarget:filter];
    [filter addTarget:self];
    [videoCamera startCameraCapture];
}

@end
