//
//  BookmarkViewController.m
//  Maps
//
//  Created by WU Wenzhi on 12-10-16.
//  Copyright (c) 2012年 PolyU. All rights reserved.
//

#import "BookmarkViewController.h"
#import "MapAnnotation.h"
#import "AnnotationDetail.h"
#import "ColorExtention.h"

@interface BookmarkViewController ()
@property NSInteger sortType;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation BookmarkViewController

@synthesize sortType;

@synthesize delegate;
@synthesize detailViewController;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Bookmarks", @"Bookmarks");
    }
    return self;
}

- (void)buttonsSetup 
{
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    NSArray *array = [NSArray arrayWithObjects:@"Bookmark Date", @"Bookmark Type", nil];
    UISegmentedControl *sortSegmentedControl = [[UISegmentedControl alloc] initWithItems:array];
    [sortSegmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    sortSegmentedControl.frame = CGRectMake(0, 0, 295, 30);
    sortSegmentedControl.selectedSegmentIndex = 0;
    [sortSegmentedControl addTarget:self action:@selector(changeFetchResultController:) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    UIBarButtonItem *segmentedControlButtonItem = [[UIBarButtonItem alloc] initWithCustomView:(UIView *)sortSegmentedControl];
    
    NSArray *toolbarItem = [[NSArray alloc] initWithObjects:fixedSpace, segmentedControlButtonItem, fixedSpace, nil];
        [self setToolbarItems:toolbarItem];
    self.navigationItem.rightBarButtonItem = cancelButton;
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    //self.navigationItem.prompt = NSLocalizedString(@"Choose a bookmark to view on the map", @"Choose a bookmark to view on the map");
}

- (void)fetchResultControllerSetup
{
    self.sortType = FetchResultsDate; //init with date sort
    self.fetchedResultsController.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.    
    [self buttonsSetup];
    [self fetchResultControllerSetup];
    [self fetchedResultsControllerBySortType];
}

- (void)viewDidUnload
{
    [self setDetailViewController:nil];
    [self setDelegate:nil];
    [self setFetchedResultsController:nil];
    [self setManagedObjectContext:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)cancel
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)changeFetchResultController:(UISegmentedControl *)sender 
{
    self.sortType = sender.selectedSegmentIndex;
    [self fetchedResultsControllerBySortType];
    [self.tableView reloadData];
}

#pragma mark - FetchResultController Settings

- (void)fetchedResultsControllerBySortType
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MapAnnotation" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    switch (self.sortType) {
        case FetchResultsDate: {
            // Edit the sort key as appropriate.
            NSLog(@"date");
            NSSortDescriptor *daySortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"day" ascending:NO];
            NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
            NSArray *sortDescriptors = [NSArray arrayWithObjects:daySortDescriptor, timeSortDescriptor, nil];
            [fetchRequest setSortDescriptors:sortDescriptors];
            // Edit the section name key path and cache name if appropriate.
            // nil for section name key path means "no sections".
            NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"day" cacheName:@"MapCache"];
            
            aFetchedResultsController.delegate = self;
            self.fetchedResultsController = aFetchedResultsController;
        } break;
            
        default: {
            // Edit the sort key as appropriate.
            NSLog(@"type");
            NSSortDescriptor *typeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"annoType" ascending:YES];
            NSSortDescriptor *daySortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"day" ascending:NO];
            NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
            NSArray *sortDescriptors = [NSArray arrayWithObjects:typeSortDescriptor, daySortDescriptor, timeSortDescriptor, nil];
            [fetchRequest setSortDescriptors:sortDescriptors];
            // Edit the section name key path and cache name if appropriate.
            // nil for section name key path means "no sections".
            NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"annoType" cacheName:@"MapCache"];
            aFetchedResultsController.delegate = self;
            self.fetchedResultsController = aFetchedResultsController;
        } break;
    }

	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
}

- (NSString *)sectionTitle:(NSString *)string
{
    switch (self.sortType) {
        case 0: {
            return string;
        } break;
            
        default: {
            switch ([string intValue]) {
                case AnnotationLocation: {
                    return @"Location Bookmark";
                } break;
                    
                case AnnotationPath: {
                    return @"Path Bookmark";
                } break;
                    
                default: {
                    return @"Region Bookmark";
                } break;
            }
        } break;
    }
}

#pragma mark - Table View Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    id <NSFetchedResultsSectionInfo> theSection = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [self sectionTitle:[theSection name]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    MapAnnotation *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = object.activity;
    cell.detailTextLabel.numberOfLines = 3;
        
    NSString *title;
    //manage the cell here...
    if (self.sortType != FetchResultsDate) {
        title = object.day;
    } else {
        switch ([object.annoType intValue]) {
            case AnnotationLocation: {
                title = @"Location Bookmark";
            } break;
                
            case AnnotationPath: {
                title = @"Path Bookmark";
            } break;
                
            default: {
                title = @"Region Bookmark";  
            } break;
        }
    }
    
    if ([object.annoType intValue] != AnnotationPath) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n%@", title, object.locationName];
    } else {
        NSArray *strings = [object.locationName componentsSeparatedByString:@"/"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\nFrom %@ To %@", title, [strings objectAtIndex:0], [strings objectAtIndex:1]];
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        MapAnnotation *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [context deleteObject:object];
        
        [delegate bookmarkViewController:self didRemoveBookmarkObjectID:object.annoID];
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

#pragma mark - Fetched results controller

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MapAnnotation *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [delegate bookmarkViewController:self didMapViewFocusOnBookmarkObjectID:object.annoID];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    //push detailViewController here...
    MapAnnotation *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    AnnotationDetail *detail = object.detail;
    if (!self.detailViewController) {
        self.detailViewController = [[BookmarkDetailController alloc] initWithNibName:@"BookmarkDetailController" bundle:nil];
    }
    [detailViewController setObject:detail];
    [self.navigationController pushViewController:self.detailViewController animated:YES];
}

@end
