//
//  UIViewController+ModalDetection.m
//  Snowball
//
//  Created by James Martinez on 7/28/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "UIViewController+ModalDetection.h"

@implementation UIViewController (ModalDetection)

- (BOOL)isModal {
    return self.presentingViewController.presentedViewController == self
    || self.navigationController.presentingViewController.presentedViewController == self.navigationController
    || [self.tabBarController.presentingViewController isKindOfClass:[UITabBarController class]];
}

@end
