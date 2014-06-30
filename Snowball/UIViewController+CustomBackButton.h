//
//  UIViewController+CustomBackButton.h
//  Snowball
//
//  Created by James Martinez on 6/30/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (CustomBackButton)

typedef NS_ENUM(NSInteger, UIViewControllerBackButtonStyle) {
    UIViewControllerBackButtonStyleLight,
    UIViewControllerBackButtonStyleDark
};

- (void)setBackButtonStyle:(UIViewControllerBackButtonStyle)style;

@end
