//
//  SBCameraNavigationBar.m
//  Snowball
//
//  Created by James Martinez on 5/19/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBCameraNavigationBar.h"

#pragma mark - SBCameraNavigationBarManager
// This is the singleton that backs the view

@interface SBCameraNavigationBarManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageView *filterView;

@end

@implementation SBCameraNavigationBarManager

+ (instancetype)sharedManager {
    static SBCameraNavigationBarManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [SBCameraNavigationBarManager new];
    });
    return sharedManager;
}

@end

#pragma mark - SBCameraNavigationBar
// This is the view itself.

@interface SBCameraNavigationBar ()

@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageView *filterView;

@end

@implementation SBCameraNavigationBar

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setCameraEnabled:YES];
    }
    return self;
}

- (void)setCameraEnabled:(BOOL)cameraEnabled {
    if (cameraEnabled) {
        _cameraEnabled = YES;

        unless (self.videoCamera) {
            [self setVideoCamera:[[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetLow cameraPosition:AVCaptureDevicePositionBack]];
            [self.videoCamera setFrameRate:24];
            [self.videoCamera setOutputImageOrientation:UIInterfaceOrientationPortrait];
            
            GPUImageGaussianBlurFilter *gaussianBlurFilter = [GPUImageGaussianBlurFilter new];
            [gaussianBlurFilter setBlurPasses:1];
            [gaussianBlurFilter setBlurRadiusInPixels:4];
            
            [self setFilterView:[[GPUImageView alloc] initWithFrame:self.bounds]];
            [self.filterView setFillMode:kGPUImageFillModePreserveAspectRatioAndFill];
            
            [self.videoCamera addTarget:gaussianBlurFilter];
            [gaussianBlurFilter addTarget:self.filterView];
        }

        [self.videoCamera startCameraCapture];
        [self insertSubview:self.filterView atIndex:0];
    }
    else {
        [self.filterView removeFromSuperview];
        [self.videoCamera stopCameraCapture];
        [self setFilterView:nil];
        [self setVideoCamera:nil];
    }
}

- (GPUImageVideoCamera *)videoCamera {
    return [SBCameraNavigationBarManager sharedManager].videoCamera;
}

- (void)setVideoCamera:(GPUImageVideoCamera *)videoCamera {
    [[SBCameraNavigationBarManager sharedManager] setVideoCamera:videoCamera];
}

- (GPUImageView *)filterView {
    return [SBCameraNavigationBarManager sharedManager].filterView;
}

- (void)setFilterView:(GPUImageView *)filterView {
    [[SBCameraNavigationBarManager sharedManager] setFilterView:filterView];
}

@end
