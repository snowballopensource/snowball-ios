//
//  SBFullScreenCameraView.m
//  Snowball
//
//  Created by James Martinez on 5/30/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBCameraManager.h"
#import "SBFullScreenCameraView.h"

@implementation SBFullScreenCameraView

- (void)startCamera {
    GPUImageVideoCamera *videoCamera = [SBCameraManager sharedManager].videoCamera;

    [self setFillMode:kGPUImageFillModePreserveAspectRatioAndFill];
    
    [videoCamera removeAllTargets];
    [videoCamera addTarget:self];
    [videoCamera startCameraCapture];
}

@end
