//
//  SBManagedTableViewController.h
//  Snowball
//
//  Created by James Martinez on 5/13/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBManagedViewController.h"

@interface SBManagedTableViewController : SBManagedViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic) BOOL pullToRefreshEnabled;
@property (nonatomic) BOOL infiniteScrollEnabled;
@property (nonatomic) BOOL isLoading;
@property (nonatomic, readonly) NSUInteger currentPage;

- (NSUInteger)controller:(NSFetchedResultsController *)controller mappedSectionIndexFromOriginalSectionIndex:(NSUInteger)originalSectionIndex;
- (NSUInteger)controller:(NSFetchedResultsController *)controller originalSectionIndexFromMappedSectionIndex:(NSUInteger)mappedSectionIndex;
- (NSIndexPath *)controller:(NSFetchedResultsController *)controller mappedIndexPathFromOriginalIndexPath:(NSIndexPath *)originalIndexPath;
- (NSIndexPath *)controller:(NSFetchedResultsController *)controller originalIndexPathFromMappedIndexPath:(NSIndexPath *)mappedIndexPath;

@end
