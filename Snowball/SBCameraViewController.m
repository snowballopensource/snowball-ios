//
//  SBCameraViewController.m
//  Snowball
//
//  Created by James Martinez on 6/4/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBCameraManager.h"
#import "SBCameraViewController.h"

@interface SBCameraViewController ()

@property (nonatomic, weak) IBOutlet UIButton *recordButton;
@property (nonatomic, weak) IBOutlet UIButton *flipCameraButton;

@end

@implementation SBCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    SBCameraPreviewView *previewView = [SBCameraManager sharedManager].previewView;
    [previewView setFrame:self.view.frame];
    [self.view insertSubview:previewView atIndex:0];
}

#pragma mark View Actions

- (IBAction)toggleMovieRecording:(id)sender {
    if ([[SBCameraManager sharedManager] isRecording]) {
        [[SBCameraManager sharedManager] stopRecording];
        [self.flipCameraButton setEnabled:YES];
        [self.recordButton setTitle:@"CAPTURE" forState:UIControlStateNormal];
    } else {
        [self.flipCameraButton setEnabled:NO];
        [self.recordButton setTitle:@"Stop Capture" forState:UIControlStateNormal];
        [[SBCameraManager sharedManager] startRecording];
    }
}

- (IBAction)changeCamera:(id)sender {
    [[SBCameraManager sharedManager] changeCamera];
}

- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint tapPoint = [(AVCaptureVideoPreviewLayer *)[self.view layer] captureDevicePointOfInterestForPoint:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [[SBCameraManager sharedManager] focusAndExposePoint:tapPoint];
}

@end
