//
//  SBCameraNavigationBar.m
//  Snowball
//
//  Created by James Martinez on 5/19/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBCameraNavigationBar.h"

@interface SBCameraNavigationBar ()

@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;

@end

@implementation SBCameraNavigationBar

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupCamera];
    }
    return self;
}

- (void)setupCamera {
    [self setVideoCamera:[[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetLow cameraPosition:AVCaptureDevicePositionBack]];
    [self.videoCamera setFrameRate:24];
    [self.videoCamera setOutputImageOrientation:UIInterfaceOrientationPortrait];
    
    GPUImageGaussianBlurFilter *gaussianBlurFilter = [GPUImageGaussianBlurFilter new];
    [gaussianBlurFilter setBlurPasses:1];
    [gaussianBlurFilter setBlurRadiusInPixels:4];

    GPUImageView *filterView = [[GPUImageView alloc] initWithFrame:self.bounds];
    [filterView setFillMode:kGPUImageFillModePreserveAspectRatioAndFill];
    
    [self.videoCamera addTarget:gaussianBlurFilter];
    [gaussianBlurFilter addTarget:filterView];
    
    [self.videoCamera startCameraCapture];
    
    [self insertSubview:filterView atIndex:0];
}

@end
