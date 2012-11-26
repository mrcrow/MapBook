//
//  MapViewControllerViewController.h
//  Maps
//
//  Created by WU Wenzhi on 12-9-29.
//  Copyright (c) 2012年 PolyU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "BookmarkViewController.h"
#import "AddBookmarkViewController.h"
#import "AnnotationDetailController.h"

enum {
    UserInputLocation = 1,
    UserInputPath,
    UserInputRegion
};
typedef NSInteger UserInputMode;

@interface MapBookViewController : UIViewController <MKMapViewDelegate, UIActionSheetDelegate, NSFetchedResultsControllerDelegate, BookmarkViewControllerDelegat, AddBookmarkViewControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) UINavigationController *overlayListViewController;
@property (strong, nonatomic) AnnotationDetailController *annotationController;

@property (weak, nonatomic) IBOutlet UIImageView *targetImage;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
