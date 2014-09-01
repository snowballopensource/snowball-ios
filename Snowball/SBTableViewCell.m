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

+ (void)registerClassToTableView:(UITableView *)tableView {
    [tableView registerClass:[self class] forCellReuseIdentifier:[self identifier]];
}

+ (void)registerNibToTableView:(UITableView *)tableView {
    [tableView registerNib:[UINib nibWithNibName:[self identifier] bundle:nil]
    forCellReuseIdentifier:[self identifier]];
}

- (void)configureForObject:(id)object {
    REQUIRE_SUBCLASS
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    
    [self.textLabel setTextColor:tintColor];
}

@end
