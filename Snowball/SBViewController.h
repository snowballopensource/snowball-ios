//
//  SBViewController.h
//  Snowball
//
//  Created by James Martinez on 5/7/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBViewController : UIViewController

typedef NS_ENUM(NSInteger, SBViewControllerBackButtonStyle) {
    SBViewControllerBackButtonStyleLight,
    SBViewControllerBackButtonStyleDark
};

+ (NSString *)identifier;
- (void)setBackButtonStyle:(SBViewControllerBackButtonStyle)style;

@end
