//
//  SBCameraViewController.m
//  Snowball
//
//  Created by James Martinez on 6/4/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBCameraManager.h"
#import "SBCameraViewController.h"

@interface SBCameraViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, weak) IBOutlet UIButton *flipCameraButton;

@property (nonatomic, weak) IBOutlet UIProgressView *progressView;
@property (nonatomic, weak) NSTimer *cameraTimer;

@end

@implementation SBCameraViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    SBCameraPreviewView *previewView = [SBCameraManager sharedManager].previewView;
    [previewView setFrame:self.view.frame];
    [self.view insertSubview:previewView atIndex:0];
    
    [self.progressView setTransform:CGAffineTransformMakeScale(1.0, 5.0)];
    [self.progressView setHidden:YES];
}

#pragma mark - View Actions

- (IBAction)toggleCapture:(id)sender {
    switch (self.longPressGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            double maxTime = 10.0; // this only changes the progress bar, not the video max length
            double fireInterval = 1.0/24.0; // 24 fps
            __block double elapsedTime;
            [self.progressView setProgress:0];
            [self.progressView setHidden:NO];
            [self setCameraTimer:[NSTimer bk_scheduledTimerWithTimeInterval:fireInterval
                                                                      block:^(NSTimer *timer) {
                                                                          elapsedTime += fireInterval;
                                                                          if (elapsedTime < maxTime) {
                                                                              [self.progressView setProgress:elapsedTime/maxTime
                                                                                                    animated:YES];
                                                                          } else {
                                                                              [timer invalidate];
                                                                              [self.longPressGestureRecognizer setEnabled:FALSE]; // cancel touches
                                                                              [self.progressView setHidden:YES];
                                                                          }
                                                                      }
                                                                    repeats:YES]];
            [[SBCameraManager sharedManager] startRecording];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            [self.longPressGestureRecognizer setEnabled:FALSE];
            [self.cameraTimer invalidate];
            [self showSpinner];
            [[SBCameraManager sharedManager] stopRecordingWithCompletion:^(NSURL *fileURL) {
                [self hideSpinner];
                [self.longPressGestureRecognizer setEnabled:TRUE];
                if (self.recordingCompletionBlock) self.recordingCompletionBlock(fileURL);
            }];
        }
            break;
        default:
            break;
    }
}

- (IBAction)flipCamera:(id)sender {
    [[SBCameraManager sharedManager] changeCamera];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.flipCameraButton]) {
        return NO;
    }
    return YES;
}

@end
