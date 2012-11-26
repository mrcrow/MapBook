//
//  BookmarkViewController.h
//  Maps
//
//  Created by WU Wenzhi on 12-10-16.
//  Copyright (c) 2012年 PolyU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "BookmarkDetailController.h"

enum {
    AnnotationLocation = 1,
    AnnotationPath = 2,
    AnnotationRegion = 3,
};
typedef NSInteger AnnotationType;

enum {
    FetchResultsDate = 0,
    FetchResultsBookmark = 1,
};
typedef NSInteger FetchResultType;

@protocol BookmarkViewControllerDelegat;

@interface BookmarkViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, weak) id <BookmarkViewControllerDelegat> delegate;

@property (strong, nonatomic) BookmarkDetailController *detailViewController;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@protocol BookmarkViewControllerDelegat

- (void)bookmarkViewController:(BookmarkViewController *)controller didMapViewFocusOnBookmarkObjectID:(NSString *)objectID;
- (void)bookmarkViewController:(BookmarkViewController *)controller didRemoveBookmarkObjectID:(NSString *)objectID;

@end