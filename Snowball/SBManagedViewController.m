//
//  SBManagedViewController.m
//  Snowball
//
//  Created by James Martinez on 5/13/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBManagedViewController.h"

@interface SBManagedViewController ()

@end

@implementation SBManagedViewController

#pragma mark - Accessors

- (NSFetchedResultsController *)fetchedResultsController {
	if (!_fetchedResultsController) {
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:[self fetchRequest]
                                                                        managedObjectContext:[NSManagedObjectContext MR_defaultContext]
                                                                          sectionNameKeyPath:self.sectionNameKeyPath
                                                                                   cacheName:nil];
        [_fetchedResultsController setDelegate:self];
        [_fetchedResultsController performFetch:nil];
	}
	return _fetchedResultsController;
}

#pragma mark - Configuration

- (NSFetchRequest *)fetchRequest {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Xcode gets confused between -entityName (NSFetchRequest) and +entityName (mogenerator)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-method-access"
    NSString *entityName = [self.entityClass entityName];
#pragma GCC diagnostic pop
    [fetchRequest setEntity:[NSEntityDescription entityForName:entityName
                                        inManagedObjectContext:[NSManagedObjectContext MR_defaultContext]]];
    [fetchRequest setSortDescriptors:self.sortDescriptors];
    [fetchRequest setPredicate:self.predicate];
	return fetchRequest;
}

- (Class)entityClass {
    unless (_entityClass) {
        REQUIRE_SUBCLASS
    }
	return _entityClass;
}

- (NSArray *)sortDescriptors {
    unless (_sortDescriptors) {
        REQUIRE_SUBCLASS
    }
	return _sortDescriptors;
}

@end
