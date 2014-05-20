//
//  UIViewController+StatusBar.m
//  Snowball
//
//  Created by James Martinez on 5/19/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import <objc/runtime.h>
#import "UIViewController+StatusBar.h"

@implementation UIViewController (StatusBar)

#pragma mark - Method Swizzling

+ (void)load {
    Method prefersStatusBarHidden = class_getInstanceMethod(self, @selector(prefersStatusBarHidden));
    Method prefersStatusBarHiddenCustom = class_getInstanceMethod(self, @selector(prefersStatusBarHiddenCustom));
    method_exchangeImplementations(prefersStatusBarHidden, prefersStatusBarHiddenCustom);
}

- (BOOL)prefersStatusBarHiddenCustom {
    return YES;
}

@end
