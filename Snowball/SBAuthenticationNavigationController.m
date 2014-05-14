//
//  SBAuthenticationNavigationController.m
//  Snowball
//
//  Created by James Martinez on 5/14/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBAuthenticationNavigationController.h"

@interface SBAuthenticationNavigationController ()

@end

@implementation SBAuthenticationNavigationController

- (void)dismiss {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [storyboard instantiateInitialViewController];
    [UIView transitionWithView:[UIApplication sharedApplication].delegate.window
                      duration:.8
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        // Without disabling and reenabling animations, some funky things happen.
                        // http://stackoverflow.com/questions/8053832/rootviewcontroller-animation-transition-initial-orientation-is-wrong
                        BOOL oldState = [UIView areAnimationsEnabled];
                        [UIView setAnimationsEnabled:NO];
                        [[UIApplication sharedApplication].delegate.window setRootViewController:vc];
                        [UIView setAnimationsEnabled:oldState];
                    }
                    completion:nil];
}

@end
