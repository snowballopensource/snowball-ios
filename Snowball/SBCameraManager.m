//
//  SBCameraManager.m
//  Snowball
//
//  Created by James Martinez on 5/28/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBCameraManager.h"

@implementation SBCameraManager

+ (instancetype)sharedManager {
    static SBCameraManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [SBCameraManager new];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initializeCamera];
    }
    return self;
}

#pragma mark - Private

- (void)initializeCamera {
    [self setVideoCamera:[[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack]];
    [self.videoCamera setFrameRate:30];
    [self.videoCamera setOutputImageOrientation:UIInterfaceOrientationPortrait];
}

@end
