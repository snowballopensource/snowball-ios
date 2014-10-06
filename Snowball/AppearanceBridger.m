//
//  AppearanceBridger.m
//  Snowball
//
//  Created by James Martinez on 10/6/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "AppearanceBridger.h"

@implementation AppearanceBridger

+ (void)setAppearance {
  // UITableViewHeaderFooterView
  [[UIView appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setBackgroundColor:[UIColor whiteColor]];
  [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setFont:[UIFont systemFontOfSize:14.0f]];
  [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextColor:[UIColor colorWithRed:114/255.0 green:214/255.0 blue:235/255.0 alpha:1.0]];
}

@end
