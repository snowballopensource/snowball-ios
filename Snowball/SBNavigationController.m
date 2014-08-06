//
//  SBNavigationController.m
//  Snowball
//
//  Created by James Martinez on 6/4/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBNavigationController.h"

@interface SBNavigationController ()

@end

@implementation SBNavigationController

+ (NSString *)identifier {
    return NSStringFromClass(self);
}

- (void)switchToStoryboardWithName:(NSString *)name {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:name bundle:nil];
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
    });
}

@end
