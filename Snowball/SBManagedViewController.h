//
//  SBManagedViewController.h
//  Snowball
//
//  Created by James Martinez on 5/13/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBViewController.h"

@interface SBManagedViewController : SBViewController

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) Class entityClass;
@property (nonatomic, strong) NSArray *sortDescriptors;
@property (nonatomic, strong) NSPredicate *predicate;
@property (nonatomic, strong) NSString *sectionNameKeyPath;

@end
