//
//  SBViewController.m
//  Snowball
//
//  Created by James Martinez on 5/7/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBViewController.h"

@interface SBViewController ()

@end

@implementation SBViewController

+ (NSString *)identifier {
    return NSStringFromClass(self);
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setBackButtonStyle:UIViewControllerBackButtonStyleLight];
}

#pragma mark - Actions

- (IBAction)dismissModal:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
