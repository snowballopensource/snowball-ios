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

@end

@implementation SBCameraViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    SBCameraPreviewView *previewView = [SBCameraManager sharedManager].previewView;
    [previewView setFrame:self.view.frame];
    [self.view insertSubview:previewView atIndex:0];
}

#pragma mark - View Actions

- (IBAction)toggleCapture:(id)sender {
    switch (self.longPressGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            [[SBCameraManager sharedManager] startRecording];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            [self.longPressGestureRecognizer setEnabled:FALSE];
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
