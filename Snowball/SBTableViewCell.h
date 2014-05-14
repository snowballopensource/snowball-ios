//
//  SBTableViewCell.h
//  Snowball
//
//  Created by James Martinez on 5/13/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBTableViewCell : UITableViewCell

+ (NSString *)identifier;
+ (CGFloat)height;

+ (void)registerNibToTableView:(UITableView *)tableView;

@end
