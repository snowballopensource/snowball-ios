//
//  SBTableViewCell.m
//  Snowball
//
//  Created by James Martinez on 5/13/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBTableViewCell.h"

@implementation SBTableViewCell

+ (NSString *)identifier {
    return NSStringFromClass(self);
}

+ (CGFloat)height {
    return 44;
}

+ (void)registerNibToTableView:(UITableView *)tableView {
    [tableView registerNib:[UINib nibWithNibName:[self identifier] bundle:nil]
    forCellReuseIdentifier:[self identifier]];
}

@end
