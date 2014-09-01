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

+ (void)registerClassToTableView:(UITableView *)tableView;
+ (void)registerNibToTableView:(UITableView *)tableView;

- (void)configureForObject:(id)object;

@end
