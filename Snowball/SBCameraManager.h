//
//  SBCameraManager.h
//  Snowball
//
//  Created by James Martinez on 5/28/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 *
 * SBCameraManager manages an SBCameraPreviewView, similar to to the way a view controller manages a view, but the
 * major difference is that this class is a singleton.
 * The preview view that this class creates is a single view that can get shared across the app.
 *
 */

@interface SBCameraPreviewView : UIView

@property (nonatomic, strong) AVCaptureSession *captureSession;

@end

@interface SBCameraManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, strong) SBCameraPreviewView *previewView;

- (void)startRecording;
- (void)stopRecordingWithCompletion:(void(^)(NSURL *fileURL))completion;
- (BOOL)isRecording;
- (void)changeCamera;
- (void)focusAndExposePoint:(CGPoint)point;

@end