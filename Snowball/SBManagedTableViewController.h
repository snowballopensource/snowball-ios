//
//  SBManagedTableViewController.h
//  Snowball
//
//  Created by James Martinez on 5/13/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBManagedViewController.h"

@interface SBManagedTableViewController : SBManagedViewController

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic) BOOL pullToRefreshEnabled;
@property (nonatomic) BOOL infiniteScrollEnabled;
@property (nonatomic) BOOL isLoading;
@property (nonatomic, readonly) NSUInteger currentPage;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

@end
