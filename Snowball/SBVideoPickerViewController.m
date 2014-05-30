//
//  SBVideoPickerViewController.m
//  Snowball
//
//  Created by James Martinez on 5/29/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBFullScreenCameraView.h"
#import "SBVideoPickerViewController.h"

@interface SBVideoPickerViewController ()

@end

@implementation SBVideoPickerViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [(SBFullScreenCameraView *)self.view startCamera];
}

#pragma mark - Actions

- (IBAction)dismissViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
