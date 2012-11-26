//
//  MapViewControllerViewController.m
//  Maps
//
//  Created by WU Wenzhi on 12-9-29.
//  Copyright (c) 2012年 PolyU. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "MapBookViewController.h"
#import "LocationBookmark.h"
#import "PathBookmark.h"
#import "RegionBookmark.h"
#import "ColorExtention.h"
#import "MapAnnotation.h"
#import "AnnotationDetail.h"

@interface MapBookViewController ()

@property (strong, nonatomic) UIBarButtonItem               *overlaysButton;
@property (strong, nonatomic) UIBarButtonItem               *cancelButton;
@property (strong, nonatomic) UIBarButtonItem               *doneButton;
@property (strong, nonatomic) UIBarButtonItem               *trashButton;
@property (strong, nonatomic) UIBarButtonItem               *addButton;

@property (strong, nonatomic) UIBarButtonItem               *typeSelectionButton;

@property (strong, nonatomic) UIActionSheet                 *selectionActionSheet;
@property (strong, nonatomic) UIActionSheet                 *cancelActionSheet;

@property (strong, nonatomic) NSMutableArray                *userInputPoints;
@property (strong, nonatomic) NSMutableArray                *userInputAnnotations;

@property (strong, nonatomic) UILongPressGestureRecognizer  *lpgr;

// 1 for point, 2 for polyline, 3 for polygon
@property                     UserInputMode                 inputMode;

@end

@implementation MapBookViewController
@synthesize overlaysButton =        _overlaysButton;
@synthesize cancelButton =          _cancelButton;
@synthesize doneButton =            _doneButton;
@synthesize trashButton =           _trashButton;
@synthesize addButton =             _addButton;
@synthesize typeSelectionButton =   _typeSelectionButton;

@synthesize selectionActionSheet =  _selectionActionSheet;
@synthesize cancelActionSheet =     _cancelActionSheet;

@synthesize lpgr;
@synthesize inputMode;
@synthesize userInputAnnotations;
@synthesize userInputPoints;

@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext =  __managementObjectContext;
@synthesize overlayListViewController;
@synthesize annotationController;
@synthesize targetImage =           _targetImage;
@synthesize mapView =               _mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        // Custom initialization
        self.title = NSLocalizedString(@"MapBook", @"MapBook");
    }
    return self;
}

#pragma mark - Setup Buttons 

- (void)mapViewSetup
{
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.delegate = self;
    //set target image
    self.targetImage.hidden = YES;
}

- (void)buttonsSetup
{
    MKUserTrackingBarButtonItem *trackingButton = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    
    UIBarButtonItem *mapTypeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPageCurl target:self action:@selector(performCurveAnimation)];
    
    self.overlaysButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(showOverlayList)];
    self.overlaysButton.style = UIBarButtonItemStyleBordered;
    self.cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(noteCancel)];
    self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(noteSave)];
    self.trashButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemUndo target:self action:@selector(noteRemoveLastAnnotationFromMapView)];
    self.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNoteToMapView)];
    self.addButton.style = UIBarButtonItemStyleBordered;
        
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    self.typeSelectionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(noteTypeSelection)];
    self.typeSelectionButton.style = UIBarButtonItemStyleBordered;

    //add button to toolbar
    NSArray *toolBarItems = [NSArray arrayWithObjects:trackingButton, fixedSpace, self.typeSelectionButton, fixedSpace, mapTypeButton, nil];
    [self setToolbarItems:toolBarItems];
    
    //add button to navigation bar
    self.navigationItem.rightBarButtonItem = self.overlaysButton;
}

- (void)annotationRetainerSetup
{
    self.userInputAnnotations = [[NSMutableArray alloc] init];
    self.userInputPoints = [[NSMutableArray alloc] init];
}

#pragma mark - App StartUp Loading

- (void)loadAnnotations
{
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeAnnotations:self.mapView.annotations];
    for (MapAnnotation *object in self.fetchedResultsController.fetchedObjects) {
        [self createAnnotation:object];
    }
}

- (void)createAnnotation:(MapAnnotation *)object
{
    switch ([object.annoType intValue]) {
        case 1: {
            //point annotation
            CGPoint point = [[[NSKeyedUnarchiver unarchiveObjectWithData:object.coordinatePoints] objectAtIndex:0] CGPointValue];
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(point.x, point.y);
            
            LocationBookmark *mark = [[LocationBookmark alloc] initWithCoordinate:coord objectID:object.annoID activity:object.activity location:object.locationName];
            [self.mapView addAnnotation:mark];
        } break;
            
        case 2: {
            //path annotation
            NSArray *points = [NSKeyedUnarchiver unarchiveObjectWithData:object.coordinatePoints];
            CLLocationCoordinate2D coords[[points count]];
            for (int i = 0; i < [points count]; i++)
            {
                coords[i] = CLLocationCoordinate2DMake([[points objectAtIndex:i] CGPointValue].x, [[points objectAtIndex:i] CGPointValue].y);
            }         
            MKPolyline *path = [MKPolyline polylineWithCoordinates:coords count:[points count]];
            
            NSArray *positions = [object.locationName componentsSeparatedByString:@"/"];
                    
            for (int i = 0; i < 2; i ++) {
                if (i == 0) {
                    CLLocationCoordinate2D start = CLLocationCoordinate2DMake([[points objectAtIndex:0] CGPointValue].x, [[points objectAtIndex:0] CGPointValue].y);
                    NSString *position = [NSString stringWithFormat:@"Start at %@", [positions objectAtIndex:0]];
                    PathBookmark *mark = [[PathBookmark alloc] initWithPolyline:path coordinate:start objectID:object.annoID activity:object.activity position:position];
                    [self.mapView addAnnotation:mark];
                } else {
                    CLLocationCoordinate2D end = CLLocationCoordinate2DMake([[points lastObject] CGPointValue].x, [[points lastObject] CGPointValue].y);
                     NSString *position = [NSString stringWithFormat:@"Finished at %@", [positions objectAtIndex:1]];
                    PathBookmark *mark = [[PathBookmark alloc] initWithPolyline:path coordinate:end objectID:object.annoID activity:object.activity position:position];
                    [self.mapView addAnnotation:mark];
                }
            }

        } break;
            
        case 3: {
            //region annotation
            NSArray *points = [NSKeyedUnarchiver unarchiveObjectWithData:object.coordinatePoints];
            CLLocationCoordinate2D coords[[points count]];
            for (int i = 0; i < [points count]; i++)
            {
                coords[i] = CLLocationCoordinate2DMake([[points objectAtIndex:i] CGPointValue].x, [[points objectAtIndex:i] CGPointValue].y);
            }         
            MKPolygon *region = [MKPolygon polygonWithCoordinates:coords count:[points count]];

            RegionBookmark *mark = [[RegionBookmark alloc] initWithPolygon:region objectID:object.annoID activity:object.activity location:object.locationName];
            [self.mapView addAnnotation:mark];
        } break;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self mapViewSetup];
    [self buttonsSetup];  
    [self annotationRetainerSetup];
    [self loadAnnotations];
}

- (void)viewDidUnload
{
    [self setFetchedResultsController:nil];
    [self setManagedObjectContext:nil];
    [self setOverlayListViewController:nil];
    [self setAnnotationController:nil];
    [super viewDidUnload];
    [self setOverlaysButton:nil];
    [self setCancelButton:nil];
    [self setDoneButton:nil];
    [self setTrashButton:nil];
    [self setAddButton:nil];
    [self setTypeSelectionButton:nil];
    [self setSelectionActionSheet:nil];
    [self setCancelActionSheet:nil];
    [self setLpgr:nil];
    [self setUserInputAnnotations:nil];
    [self setMapView:nil];
    [self setTargetImage:nil];
}

#pragma mark - Fetched Results Controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController) {
        return __fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MapAnnotation" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    // Edit the sort key as appropriate.
    NSSortDescriptor *daySortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"day" ascending:NO];
    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:timeSortDescriptor, daySortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"day" cacheName:@"MapCache"];
    
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return __fetchedResultsController;
}

#pragma mark - Button Methods

- (void)performCurveAnimation
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.mapView cache:YES];
    [UIView commitAnimations];
    if (self.mapView.mapType == MKMapTypeStandard) {
        self.mapView.mapType = MKMapTypeHybrid;
    } else {
        self.mapView.mapType = MKMapTypeStandard;
    }
}

- (void)showOverlayList
{
    if (!self.overlayListViewController) {
        BookmarkViewController *bookViewController = [[BookmarkViewController alloc] initWithNibName:@"BookmarkViewController" bundle:nil];
        bookViewController.delegate = self;
        bookViewController.managedObjectContext = self.managedObjectContext;
        self.overlayListViewController = [[UINavigationController alloc] initWithRootViewController:bookViewController];
        [self.overlayListViewController setToolbarHidden:NO];
    }
    [self presentModalViewController:self.overlayListViewController animated:YES];
}

- (void)noteCancel
{
    if ([userInputAnnotations count] == 0) {
        [self barTransformBackToNormalStyle];
    } else {
        if (!self.cancelActionSheet) 
        {
            self.cancelActionSheet = [[UIActionSheet alloc] initWithTitle:@"Bookmark is not saved" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Save" otherButtonTitles:@"Don't save", nil];
        }
        [self.cancelActionSheet showFromToolbar:self.navigationController.toolbar];
    }
}

- (void)addNoteToMapView
{
    CLLocationCoordinate2D mapCenterCoordinate = [self.mapView centerCoordinate];    
    
    NSValue *point = [NSValue valueWithCGPoint:CGPointMake(mapCenterCoordinate.latitude, mapCenterCoordinate.longitude)];
    
    //NSValue *point = [NSValue valueWithMKCoordinate:mapCenterCoordinate];
    
    if ([userInputPoints indexOfObject:point inRange:NSMakeRange(0, [userInputPoints count])] == NSNotFound) {
        if (self.inputMode == UserInputLocation) {
            [self noteRemoveLastAnnotationFromMapView];
        }
        
        MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
        annot.title = [NSString stringWithFormat:@"Location %d", [userInputPoints count] + 1];
        annot.coordinate = mapCenterCoordinate;
        annot.subtitle = [NSString stringWithFormat:@"φ:%.4f, λ:%.4f", annot.coordinate.latitude, annot.coordinate.longitude];
        
        [self.mapView addAnnotation:annot];
        [userInputAnnotations addObject:annot];
        [userInputPoints addObject:point];
    }
    
    [self checkInputAnnotationNumber];
}

- (void)noteRemoveLastAnnotationFromMapView
{
    if ([userInputAnnotations count] != 0) {
        MKPointAnnotation *pin = [userInputAnnotations lastObject];
        [userInputAnnotations removeLastObject];
        [userInputPoints removeLastObject];
        [self.mapView removeAnnotation:pin];
        if (self.inputMode != UserInputLocation) {
            [self.mapView setCenterCoordinate:pin.coordinate animated:YES];
        }
    }
    [self checkInputAnnotationNumber];
}

- (void)noteSave
{
    AddBookmarkViewController *addViewController = [[AddBookmarkViewController alloc] initWithNibName:@"AddBookmarkViewController" bundle:nil];
    addViewController.delegate = self;
    id <MKAnnotation> annot = [self convertPointsToAnnotation];
    NSArray *locations = [self extractLocationInfoFromAnnotation:annot];

    addViewController.managedObjectContext = self.managedObjectContext;
    [addViewController setAnnotation:annot
                                type:self.inputMode
                      coordinateInfo:self.userInputPoints 
                        locationInfo:locations 
                            objectID:[NSDate date]];
    UINavigationController *addNavigationViewController = [[UINavigationController alloc] initWithRootViewController:addViewController];
    [self presentModalViewController:addNavigationViewController animated:YES];
    [self clearMapViewAnnotations];
}

- (void)noteTypeSelection
{
    if (!self.selectionActionSheet) 
    {
        self.selectionActionSheet = [[UIActionSheet alloc] initWithTitle:@"Select bookmark" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Location Bookmark", @"Path Bookmark", @"Region Bookmark", nil];
    }
    
    [self.selectionActionSheet showFromToolbar:self.navigationController.toolbar];
}

#pragma mark - Annotation Methods

- (NSArray *)extractLocationInfoFromAnnotation:(id <MKAnnotation>)annot
{
    //point return [location], polygon return [location.center], polyline return [start, end]
    if ([annot isKindOfClass:[MKPointAnnotation class]]) 
    {
        //return point [1]
        return self.userInputPoints; 
    } 
    else if ([annot isKindOfClass:[MKPolygon class]]) 
    {
        //return mkpolygon center [1]
        MKPolygon *polygon = (MKPolygon *)annot;
        NSValue *point = [NSValue valueWithCGPoint:CGPointMake(polygon.coordinate.latitude, polygon.coordinate.longitude)];
        //NSValue *point = [NSValue valueWithMKCoordinate:polygon.coordinate]; 
        return [NSArray arrayWithObject:point];
    }
    else 
    {
        //return first and last objects [2]
        return [NSArray arrayWithObjects:[self.userInputPoints objectAtIndex:0], [self.userInputPoints lastObject], nil];
    }
}

- (id <MKAnnotation>)convertPointsToAnnotation
{
    switch (self.inputMode) {
        case UserInputLocation: {
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([[userInputPoints lastObject] CGPointValue].x, [[userInputPoints lastObject] CGPointValue].y);
            //CLLocationCoordinate2D coord = [[userInputPoints lastObject] MKCoordinateValue];
            MKPointAnnotation *location = [[MKPointAnnotation alloc] init];
            [location setCoordinate:coord];
            return location;
        } break;
        
        case UserInputPath:{
            CLLocationCoordinate2D coords[[userInputPoints count]];
            for (int i = 0; i < [userInputPoints count]; i++)
            {
                coords[i] = CLLocationCoordinate2DMake([[userInputPoints objectAtIndex:i] CGPointValue].x, [[userInputPoints objectAtIndex:i] CGPointValue].y);
                //coords[i] = [[userInputPoints objectAtIndex:i] MKCoordinateValue];
            }         
            MKPolyline *path = [MKPolyline polylineWithCoordinates:coords count:[userInputPoints count]];
            return path;
        } break;
            
        default: {
            CLLocationCoordinate2D coords[[userInputPoints count]];
            for (int i = 0; i < [userInputPoints count]; i++)
            {
                coords[i] = CLLocationCoordinate2DMake([[userInputPoints objectAtIndex:i] CGPointValue].x, [[userInputPoints objectAtIndex:i] CGPointValue].y);
                //coords[i] = [[userInputPoints objectAtIndex:i] MKCoordinateValue];
            }
            MKPolygon *polygon = [MKPolygon polygonWithCoordinates:coords count:[userInputPoints count]];
            return polygon;
        } break;
    }
}

- (void)clearMapViewAnnotations
{
    [self.mapView removeAnnotations:userInputAnnotations];
    [userInputAnnotations removeAllObjects];
    [userInputPoints removeAllObjects];
}

#pragma mark - Title Reset Method

- (void)titleReset
{
    self.title = NSLocalizedString(@"MapBook", @"MapBook");
}

#pragma mark - Action Sheet Delegate Method

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == self.selectionActionSheet) 
    {
        switch (buttonIndex) 
        {
            case 0: {
                self.title = NSLocalizedString(@"Set a pin", "Set a pin");
                [self barTransformToDrawingStyle];
                self.inputMode = UserInputLocation;
            } break;
                
            case 1:{
                self.title = NSLocalizedString(@"Create a path", "Create a path");
                [self barTransformToDrawingStyle];
                self.inputMode = UserInputPath;
            } break;
                
            case 2: {
                self.title = NSLocalizedString(@"Create a region", "Create a region");
                [self barTransformToDrawingStyle];
                self.inputMode = UserInputRegion;
            }
                
            default:
                break;
        }
    }
    
    if (actionSheet == self.cancelActionSheet) {
        switch (buttonIndex) {
            case 0: {
                [self noteSave];
                [self barTransformBackToNormalStyle];
                [self clearMapViewAnnotations];
            } break;
                
            case 1: {
                [self barTransformBackToNormalStyle];
                [self clearMapViewAnnotations];
            } break;
                
            default: {
                //do nothing
            } break;
        }
    }
}

#pragma mark - ToolBar & NavigationBar Management

- (void)barTransformToDrawingStyle
{
    self.targetImage.hidden = NO;
    
    NSMutableArray *toolBarItems = [NSMutableArray arrayWithArray:self.toolbarItems];
    [toolBarItems replaceObjectAtIndex:2 withObject:self.addButton];
    [self setToolbarItems:toolBarItems animated:YES];
    
    [self.navigationItem setLeftBarButtonItem:self.cancelButton animated:YES];
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    
    if (!self.lpgr) 
    {
        self.lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handLongPress:)];
        lpgr.minimumPressDuration = 0.5; //user needs to press for 0.5 seconds
    }
    [self.mapView addGestureRecognizer:self.lpgr];
}

- (void)barTransformBackToNormalStyle
{
    self.targetImage.hidden = YES;
    
    NSMutableArray *toolBarItems = [NSMutableArray arrayWithArray:self.toolbarItems];
    [toolBarItems replaceObjectAtIndex:2 withObject:self.typeSelectionButton];
    [self setToolbarItems:toolBarItems animated:YES];
    
    [self.navigationItem setLeftBarButtonItems:nil animated:YES];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObject:self.overlaysButton] animated:YES];
    
    [self.mapView removeGestureRecognizer:self.lpgr];
    [self titleReset];
}

- (void)navigationBarAddTrashButton
{
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:self.cancelButton, self.trashButton, nil] animated:YES];
}

- (void)navigationBarRemoveTrashButton
{
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObject:self.cancelButton] animated:YES];
}

- (void)navigationBarAddDoneButton
{
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObject:self.doneButton] animated:YES];
}

- (void)navigationBarRemoveDoneButton
{
    [self.navigationItem setRightBarButtonItems:nil animated:YES];
}

#pragma mark - Check User Annotation Input Number and Manage NavigationBar Items 

- (void)checkInputAnnotationNumber
{
    switch (self.inputMode) 
    {
        case UserInputLocation: 
        {
            if ([userInputAnnotations count] < self.inputMode) 
            {
                [self navigationBarRemoveDoneButton];
            } 
            else 
            {
                if ([self.navigationItem.rightBarButtonItems count] != 1)
                {
                    [self navigationBarAddDoneButton];
                }
            }
        } break;
            
        default:
        {
            if ([userInputPoints count] == 0) 
            {
                [self navigationBarRemoveTrashButton];
            } 
            else if ([userInputPoints count] < self.inputMode) 
            {
                [self navigationBarAddTrashButton];
                [self navigationBarRemoveDoneButton];
            }
            else
            {
                [self navigationBarAddDoneButton];
            }
        } break;
    }
}

#pragma mark - MapView Delegate Methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    } 
    else if ([annotation isKindOfClass:[MKPointAnnotation class]]) 
    {
        static NSString *MapOverlayAnnotationIdentifier = @"LocationPinAnnotationIdentifier";
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)
        [mapView dequeueReusableAnnotationViewWithIdentifier:MapOverlayAnnotationIdentifier];
        
        if (!pinView)
        {
            // if an existing pin view was not available, create one
            MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc]
                                                   initWithAnnotation:annotation reuseIdentifier:MapOverlayAnnotationIdentifier];
            customPinView.pinColor = MKPinAnnotationColorRed;
            customPinView.animatesDrop = YES;
            customPinView.canShowCallout = YES;
                        
            return customPinView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    } 
    else if ([annotation isKindOfClass:[LocationBookmark class]])
    {
        static NSString *MapOverlayAnnotationIdentifier = @"LocationBookmarkIdentifier";
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)
        [mapView dequeueReusableAnnotationViewWithIdentifier:MapOverlayAnnotationIdentifier];
        
        if (!pinView)
        {
            // if an existing pin view was not available, create one
            MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc]
                                                  initWithAnnotation:annotation reuseIdentifier:MapOverlayAnnotationIdentifier];
            customPinView.pinColor = MKPinAnnotationColorRed;
            customPinView.animatesDrop = YES;
            customPinView.canShowCallout = YES;
            
            UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [leftButton setFrame:CGRectMake(0.0f, 0.0f, 20.0, 20.0)];
            [leftButton setImage:[UIImage imageNamed:@"arrowDownRed.png"] forState:UIControlStateNormal];
            
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [rightButton setFrame:CGRectMake(0.0f, 0.0f, 20.0, 20.0)];
            [rightButton setImage:[UIImage imageNamed:@"arrowRightRed.png"] forState:UIControlStateNormal];

            customPinView.leftCalloutAccessoryView = leftButton;
            customPinView.leftCalloutAccessoryView.tag = 0;

            customPinView.rightCalloutAccessoryView = rightButton;
            customPinView.rightCalloutAccessoryView.tag = 1;
            
            return customPinView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    } 
    else if ([annotation isKindOfClass:[PathBookmark class]])
    {
        static NSString *MapOverlayAnnotationIdentifier = @"PathBookmarkIdentifier";
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)
        [mapView dequeueReusableAnnotationViewWithIdentifier:MapOverlayAnnotationIdentifier];
        
        if (!pinView)
        {
            // if an existing pin view was not available, create one
            MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc]
                                                  initWithAnnotation:annotation reuseIdentifier:MapOverlayAnnotationIdentifier];
            customPinView.pinColor = MKPinAnnotationColorGreen;
            customPinView.animatesDrop = YES;
            customPinView.canShowCallout = YES;
            
            UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [leftButton setFrame:CGRectMake(0.0f, 0.0f, 20.0f, 20.0f)];
            [leftButton setImage:[UIImage imageNamed:@"arrowDownGreen.png"] forState:UIControlStateNormal];
            
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [rightButton setFrame:CGRectMake(0.0f, 0.0f, 20.0f, 20.0f)];
            [rightButton setImage:[UIImage imageNamed:@"arrowRightGreen.png"] forState:UIControlStateNormal];
            
            customPinView.leftCalloutAccessoryView = leftButton;
            customPinView.leftCalloutAccessoryView.tag = 0;
            customPinView.rightCalloutAccessoryView = rightButton;
            customPinView.rightCalloutAccessoryView.tag = 1;
            
            return customPinView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    } 
    else if ([annotation isKindOfClass:[RegionBookmark class]]) 
    {
        static NSString *MapOverlayAnnotationIdentifier = @"RegionBookmarkIdentifier";
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)
        [mapView dequeueReusableAnnotationViewWithIdentifier:MapOverlayAnnotationIdentifier];
        
        if (!pinView)
        {
            // if an existing pin view was not available, create one
            MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc]
                                                  initWithAnnotation:annotation reuseIdentifier:MapOverlayAnnotationIdentifier];
            customPinView.pinColor = MKPinAnnotationColorPurple;
            customPinView.animatesDrop = YES;
            customPinView.canShowCallout = YES;
            
            UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [leftButton setFrame:CGRectMake(0.0f, 0.0f, 20.0, 20.0)];
            [leftButton setImage:[UIImage imageNamed:@"arrowDownPurple.png"] forState:UIControlStateNormal];
            
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [rightButton setFrame:CGRectMake(0.0f, 0.0f, 20.0, 20.0)];
            [rightButton setImage:[UIImage imageNamed:@"arrowRightPurple.png"] forState:UIControlStateNormal];
            
            customPinView.leftCalloutAccessoryView = leftButton;
            customPinView.leftCalloutAccessoryView.tag = 0;
            customPinView.rightCalloutAccessoryView = rightButton;
            customPinView.rightCalloutAccessoryView.tag = 1;
            
            return customPinView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    
    return nil;
}

- (id <MKOverlay>)overlayInAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[PathBookmark class]]) {
        PathBookmark *bookmark = (PathBookmark *)view.annotation;
        return bookmark.path;
    } else if ([view.annotation isKindOfClass:[RegionBookmark class]]) {
        RegionBookmark *bookmark = (RegionBookmark *)view.annotation;
        return bookmark.region;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view 
{
    id <MKOverlay> overlay = [self overlayInAnnotationView:view];
    if (overlay) {
        [_mapView addOverlay:overlay];
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    id <MKOverlay> overlay = [self overlayInAnnotationView:view];
    if (overlay) {
        [_mapView removeOverlay:overlay];
    }
}

- (MKCoordinateRegion)zoomIntoAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[LocationBookmark class]]) {
        return MKCoordinateRegionMakeWithDistance(view.annotation.coordinate, 200, 200);
    } else if ([view.annotation isKindOfClass:[PathBookmark class]]) {
        PathBookmark *mark = (PathBookmark *)view.annotation;
        return  MKCoordinateRegionForMapRect(mark.path.boundingMapRect);
    } else {
        RegionBookmark *mark = (RegionBookmark *)view.annotation;
        return MKCoordinateRegionForMapRect(mark.region.boundingMapRect);
    }
}

#warning manage right accesery view

- (NSString *)annotationIDFromAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[LocationBookmark class]]) {
        LocationBookmark *mark = (LocationBookmark *)view.annotation;
        return mark.annotID;
    } else if ([view.annotation isKindOfClass:[PathBookmark class]]) {
        PathBookmark *mark = (PathBookmark *)view.annotation;
        return mark.annotID;
    } else {
        RegionBookmark *mark = (RegionBookmark *)view.annotation;
        return mark.annotID;
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    switch (control.tag) {
        case 0: {
            MKCoordinateRegion region = [self zoomIntoAnnotationView:view];
            [_mapView setRegion:region animated:YES];
        } break;
            
        default: {
            // "Right Accessory Button Tapped 
            // Fetch the object 
            NSManagedObjectContext *context = self.managedObjectContext;
            NSFetchRequest *request= [[NSFetchRequest alloc] init];
            [request setEntity:[NSEntityDescription entityForName:@"MapAnnotation" inManagedObjectContext:context]];
            
            //[entities setIncludesPropertyValues:NO]; //only fetch the managedObjectID
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"annoID == %@", [self annotationIDFromAnnotationView:view]];
            [request setPredicate:predicate];
            
            NSError *error = nil;
            NSArray *fetchResult = [context executeFetchRequest:request error:&error];
            
            if (error) {
                NSLog(@"%@: Error fetching context: %@", [self class], [error localizedDescription]);
                NSLog(@"entitiesArray: %@",fetchResult);
                return;
            }
            
            MapAnnotation *object = [fetchResult objectAtIndex:0];
            if (!self.annotationController) {
                self.annotationController = [[AnnotationDetailController alloc] initWithNibName:@"AnnotationDetailController" bundle:nil];
            }
            annotationController.object = object;
            [self.navigationController pushViewController:annotationController animated:YES];
            
        } break;
    }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolygon class]]) {
        MKPolygon *polgon = overlay;
        MKPolygonView *polygonView = [[MKPolygonView alloc] initWithPolygon:polgon];
        polygonView.fillColor = [UIColor regionBookmarkFillColor];
        polygonView.strokeColor = [UIColor regionBookmarkStrokeColor];
        polygonView.lineWidth = 8.0;
        return polygonView;
    } 
    
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *polyline = overlay;
        MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:polyline];
        polylineView.fillColor = [UIColor pathBookmarkFillColor];
        polylineView.strokeColor = [UIColor pathBookmarkStrokeColor];
        polylineView.lineWidth = 8.0;
        return polylineView;
    } 
    return nil;
}

#pragma mark - UIGesture Method

- (void)handLongPress:(UIGestureRecognizer *)gestureRecognizer
{    
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
    {
        return;
    }
        
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];   
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    NSValue *point = [NSValue valueWithCGPoint:CGPointMake(touchMapCoordinate.latitude, touchMapCoordinate.longitude)];
    
    //NSValue *point = [NSValue valueWithMKCoordinate:touchMapCoordinate];
    
    if ([userInputPoints indexOfObject:point inRange:NSMakeRange(0, [userInputPoints count])] == NSNotFound) {
        if (self.inputMode == UserInputLocation) {
            [self noteRemoveLastAnnotationFromMapView];
        }
        
        MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
        annot.title = [NSString stringWithFormat:@"Location %d", [userInputPoints count] + 1];
        annot.coordinate = touchMapCoordinate;
        annot.subtitle = [NSString stringWithFormat:@"φ:%.4f, λ:%.4f", annot.coordinate.latitude, annot.coordinate.longitude];
        
        [self.mapView addAnnotation:annot];
        [userInputAnnotations addObject:annot];
        [userInputPoints addObject:point];
    }
    
    [self checkInputAnnotationNumber];
}

#pragma mark - BookmarkViewController Delegate

- (void)bookmarkViewController:(BookmarkViewController *)controller didMapViewFocusOnBookmarkObjectID:(NSString *)objectID
{
    for (id <MKAnnotation> object in self.mapView.annotations) {
        if ([object isKindOfClass:[LocationBookmark class]]) {
            LocationBookmark *mark = (LocationBookmark *)object;
            if (mark.annotID == objectID) {
                MKCoordinateRegion area = MKCoordinateRegionMakeWithDistance(mark.coordinate, 200, 200);
                [_mapView setRegion:area animated:YES];
                [self.mapView selectAnnotation:mark animated:YES];
            }
        } else if ([object isKindOfClass:[PathBookmark class]]) {
            PathBookmark *mark = (PathBookmark *)object;
            if (mark.annotID == objectID) {
                MKCoordinateRegion area = MKCoordinateRegionForMapRect(mark.path.boundingMapRect);
                [_mapView setRegion:area animated:YES];
                [self.mapView selectAnnotation:mark animated:YES];
                break;
            }
        } else {
            RegionBookmark *mark = (RegionBookmark *)object;
            if (mark.annotID == objectID) {
                MKCoordinateRegion area = MKCoordinateRegionForMapRect(mark.region.boundingMapRect);
                [_mapView setRegion:area animated:YES];
                [self.mapView selectAnnotation:mark animated:YES];
            }
        }
    }
}

- (void)bookmarkViewController:(BookmarkViewController *)controller didRemoveBookmarkObjectID:(NSString *)objectID
{
    for (id <MKAnnotation> object in self.mapView.annotations) {
        if ([object isKindOfClass:[LocationBookmark class]]) {
            LocationBookmark *mark = (LocationBookmark *)object;
            if (mark.annotID == objectID) {
                [self.mapView removeAnnotation:object];
            }
        } else if ([object isKindOfClass:[PathBookmark class]]) {
            PathBookmark *mark = (PathBookmark *)object;
            if (mark.annotID == objectID) {
                [self.mapView removeAnnotation:object];
            }
        } else {
            RegionBookmark *mark = (RegionBookmark *)object;
            if (mark.annotID == objectID) {
                [self.mapView removeAnnotation:object];
            }
        }
    }
}

#pragma mark - AddBookmarkViewController Delegate

- (void)addBookmarkViewController:(AddBookmarkViewController *)controller rootViewNavigationBarTransform:(BOOL)transform
{
    if (transform) {
        [self barTransformBackToNormalStyle];
    }
}

- (void)addBookmarkViewController:(AddBookmarkViewController *)controller addAnnotationToMapView:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[LocationBookmark class]]) {
        LocationBookmark *bookmark = (LocationBookmark *)annotation;
        [self.mapView addAnnotation:bookmark];
        
        MKCoordinateRegion area = MKCoordinateRegionMakeWithDistance(bookmark.coordinate, 200, 200);
        [_mapView setRegion:area animated:YES];
        
        [self.mapView selectAnnotation:bookmark animated:YES];
        
    } else if ([annotation isKindOfClass:[PathBookmark class]]) {
        PathBookmark *bookmark = (PathBookmark *)annotation;
        [self.mapView addAnnotation:bookmark];
        
        MKCoordinateRegion area = MKCoordinateRegionForMapRect(bookmark.path.boundingMapRect);
        [_mapView setRegion:area animated:YES];
        
        [self.mapView selectAnnotation:bookmark animated:YES];
    } else if ([annotation isKindOfClass:[RegionBookmark class]]) {
        RegionBookmark *bookmark = (RegionBookmark *)annotation;
        [self.mapView addAnnotation:bookmark];
        
        MKCoordinateRegion area = MKCoordinateRegionForMapRect(bookmark.region.boundingMapRect);
        [_mapView setRegion:area animated:YES];
        
        [self.mapView selectAnnotation:bookmark animated:YES];
    }
}

@end
