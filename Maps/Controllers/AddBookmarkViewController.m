//
//  AddBookmarkViewController.m
//  Maps
//
//  Created by WU Wenzhi on 12-10-16.
//  Copyright (c) 2012年 PolyU. All rights reserved.
//

#import "AddBookmarkViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ColorExtention.h"
#import "ActionSheetPicker.h"
#import "LocationBookmark.h"
#import "PathBookmark.h"
#import "RegionBookmark.h"
#import "MapAnnotation.h"
#import "AnnotationDetail.h"

@interface AddBookmarkViewController ()
@property (strong, nonatomic) UITextField       *titleField;

@property (strong, nonatomic) UITextField       *locationField;
@property (strong, nonatomic) UITextField       *locationFromField;
@property (strong, nonatomic) UITextField       *locationToField;

@property (strong, nonatomic) UITextView        *contentField;

@property (strong, nonatomic) UITextField       *dateField;

@property (strong, nonatomic) MKMapView         *mapView;

@property                     BookmarkType      bookmarkType;
@property (strong, nonatomic) id <MKAnnotation> overlayObject;
@property (strong, nonatomic) NSMutableArray    *coordinates;
@property (strong, nonatomic) NSMutableArray    *locationInfo;
@property (strong, nonatomic) NSDate            *objectID;

@property (strong, nonatomic) UIBarButtonItem   *cancelButton;
@property (strong, nonatomic) UIBarButtonItem   *saveButton;
@end

@implementation AddBookmarkViewController

@synthesize titleField =        _titleField;

@synthesize locationField =     _locationField;
@synthesize locationFromField = _locationFromField;
@synthesize locationToField =   _locationToField;

@synthesize contentField =        _contentField;
@synthesize dateField =         _dateField;
@synthesize mapView =           _mapView;

@synthesize cancelButton, saveButton;

@synthesize bookmarkType, overlayObject, coordinates, locationInfo, objectID;
@synthesize delegate;
@synthesize managedObjectContext = __managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Bookmark", @"Bookmark");
    }
    return self;
}

- (void)setAnnotation:(id<MKAnnotation>)annot type:(NSInteger)type coordinateInfo:(NSMutableArray *)array locationInfo:(NSArray *)info objectID:(NSDate *)date
{
    [self setOverlayObject:annot];
    [self setBookmarkType:type];
    [self setObjectID:date];
    self.coordinates = [NSMutableArray arrayWithArray:array];
    self.locationInfo = [NSMutableArray arrayWithArray:info];
}

#pragma mark - Save and Cancel

- (void)cancel
{
    UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"The bookmark will not be saved" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Yes" otherButtonTitles:nil];
    [actionsheet showInView:self.tableView];
}

- (BOOL)requiredTextFieldCheck
{
    if (self.bookmarkType != BookmarkPath) 
    {
        if ([_titleField.text length] == 0 || [_locationField.text length] == 0 || [_dateField.text length] == 0)
        {
            return NO;
        } else {
            return YES;
        }
    } 
    else
    {
        if ([_titleField.text length] == 0 || [_locationFromField.text length] == 0 || [_locationToField.text length] == 0 || [_dateField.text length] == 0) 
        {
            return NO;
        } else {
            return YES;
        }
    }
}

- (void)save
{
    if (![self requiredTextFieldCheck]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Please complete the 'Required' information" 
                                                       delegate:self
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        //code here
        [self insertMapObject];
        [self dismissModalViewControllerAnimated:YES];
        [delegate addBookmarkViewController:self rootViewNavigationBarTransform:YES];
    }
}

- (void)insertMapObject
{
    NSManagedObjectContext *context = self.managedObjectContext;
    
    //MapAnnotation Object
    MapAnnotation *mapObject = [NSEntityDescription insertNewObjectForEntityForName:@"MapAnnotation" inManagedObjectContext:context];

    //annotation ID creater
    NSDateFormatter *idFormatter = [[NSDateFormatter alloc] init];
    [idFormatter setDateFormat:@"yyyyMMddHHmmsszz"];
    NSString *idString = [idFormatter stringFromDate:self.objectID];
    
    mapObject.annoID = idString;
    mapObject.activity = _titleField.text;
    mapObject.annoType = [NSNumber numberWithInt:self.bookmarkType];
            
    NSArray *dateDictionary = [_dateField.text componentsSeparatedByString:@" "];
    NSString *dayString = [dateDictionary objectAtIndex:0];
    NSString *timeString = [dateDictionary objectAtIndex:1];
    
    mapObject.day = dayString;
    mapObject.time = timeString;
    
    switch (self.bookmarkType) {
        case BookmarkLocation: {
            mapObject.locationName = _locationField.text;
            MKPointAnnotation *annot = (MKPointAnnotation *)overlayObject;
            LocationBookmark *mark = [[LocationBookmark alloc] initWithCoordinate:annot.coordinate objectID:idString activity:mapObject.activity location:mapObject.locationName];
            [delegate addBookmarkViewController:self addAnnotationToMapView:mark];
        } break;
            
        case BookmarkPath: {
            mapObject.locationName = [NSString stringWithFormat:@"%@/%@", _locationFromField.text, _locationToField.text];
            MKPolyline *annot = (MKPolyline *)overlayObject;
            
            //create two pins for PathBookmark
            for (int i = 0; i < 2; i ++) {
                CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([[locationInfo objectAtIndex:i] CGPointValue].x, [[locationInfo objectAtIndex:i] CGPointValue].y);
                //CLLocationCoordinate2D coord = [[locationInfo objectAtIndex:i] MKCoordinateValue];
                switch (i) {
                    case 0: {
                        NSString *position = _locationFromField.text;
                        PathBookmark *mark = [[PathBookmark alloc] initWithPolyline:annot coordinate:coord objectID:idString activity:mapObject.activity position:position];
                        [delegate addBookmarkViewController:self addAnnotationToMapView:mark];
                    } break;
                        
                    default: {
                        NSString *position = _locationToField.text;
                        PathBookmark *mark = [[PathBookmark alloc] initWithPolyline:annot coordinate:coord objectID:idString activity:mapObject.activity position:position];
                        [delegate addBookmarkViewController:self addAnnotationToMapView:mark];
                    } break;
                }
            }
        } break;
            
        default: {            
            mapObject.locationName = _locationField.text;
            MKPolygon *annot = (MKPolygon *)overlayObject;
            RegionBookmark *bookmark = [[RegionBookmark alloc] initWithPolygon:annot objectID:idString activity:mapObject.activity location:mapObject.locationName];
            [delegate addBookmarkViewController:self addAnnotationToMapView:bookmark];
        } break;
    }
    
    mapObject.coordinatePoints = [NSKeyedArchiver archivedDataWithRootObject:coordinates];;
    
    //AnnotationDetail Object
    AnnotationDetail *mapObjectDetail = [NSEntityDescription insertNewObjectForEntityForName:@"AnnotationDetail" inManagedObjectContext:context];
    
    //data contains "day/time", using @"/" to seperate them
    mapObjectDetail.date = [NSString stringWithFormat:@"%@/%@", dayString, timeString];
    mapObjectDetail.story = _contentField.text;
    mapObjectDetail.title = _titleField.text;
    mapObjectDetail.type = [NSNumber numberWithInt:self.bookmarkType];
    mapObjectDetail.locationString = mapObject.locationName;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:locationInfo];
    mapObjectDetail.locationPoint = data;

    //Set relationship of MapAnnotation and AnnotationDetail
    mapObject.detail = mapObjectDetail;
    mapObjectDetail.info = mapObject;
    
    //Save
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark - UIActionSheet Delegate Method

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex) 
    {
        [self dismissModalViewControllerAnimated:YES];
        [delegate addBookmarkViewController:self rootViewNavigationBarTransform:YES];
    }
}

#pragma mark - UIButton and Text Settings

- (void)buttonsSetup
{
    self.cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
    self.navigationItem.leftBarButtonItem = self.cancelButton;
    self.navigationItem.rightBarButtonItem = self.saveButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self buttonsSetup];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setCancelButton:nil];
    [self setSaveButton:nil];
    [self setTitleField:nil];
    [self setLocationField:nil];
    [self setLocationFromField:nil];
    [self setLocationToField:nil];
    [self setContentField:nil];
    [self setDateField:nil];
    [self setMapView:nil];
    [self setObjectID:nil];
    [self setCoordinates:nil];
    [self setLocationInfo:nil];
    [self setOverlayObject:nil];
    [self setDelegate:nil];
    [self setManagedObjectContext:nil];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *counts;
    if (self.bookmarkType != BookmarkPath)
    {
        counts = [NSArray arrayWithObjects:
                  [NSNumber numberWithInt:1],   //Title
                  [NSNumber numberWithInt:1],   //Content
                  [NSNumber numberWithInt:1],   //Date
                  [NSNumber numberWithInt:1],   //Map
                  [NSNumber numberWithInt:1],   //Coordinate
                  [NSNumber numberWithInt:1],   //Location
                  nil];
    } 
    else {
        counts = [NSArray arrayWithObjects:
                  [NSNumber numberWithInt:1],   //Title
                  [NSNumber numberWithInt:1],   //Content
                  [NSNumber numberWithInt:1],   //Date
                  [NSNumber numberWithInt:1],   //Map
                  [NSNumber numberWithInt:2],   //Coordinates
                  [NSNumber numberWithInt:2],   //Locations
                  nil];
    }
    return [[counts objectAtIndex:section] intValue];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *titles;
    if (self.bookmarkType != BookmarkPath) {
        titles = [NSArray arrayWithObjects:
                  @"",                         
                  @"Content",               
                  @"",                 
                  @"Map Annotation",                      
                  @"",                     
                  @"",                  
                  nil];
    } else {
        titles = [NSArray arrayWithObjects:
                  @"",                         
                  @"Content",                          
                  @"",                          
                  @"Map Annotation",                
                  @"Locations",                     
                  @"Coordinates",                   
                  nil];
    }

    return [titles objectAtIndex:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{   
    if (section == 1) {
        return @"Enter the ending symbols (e.g. '. ! ?') can help you to start a new paragraph.";
    } 

    if (section == 5) 
    {
        if (self.bookmarkType != BookmarkPath) {
            return @"Select the 'Coordinate' cell can fill the 'Location' cell with default address";
        } else {
            return @"Select the 'Coordinates' cells can fill the 'Locations' cells with default address";
        }
    } 
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)                 //Content
    {
        return 280.0f;
    }
    
    if (indexPath.section == 3)
    { 
        return 240.0f;                          //Map
    } 

    return [self.tableView rowHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    if (self.bookmarkType != BookmarkPath) {
        switch (section) {
            case 0: return [self cellForTitle];
            case 1: return [self cellForContent];
            case 2: return [self cellForDate];
            case 3: return [self cellForMapView];
            case 4: return [self cellForLocation];
            case 5: return [self cellForCoordinate];
            default: return nil;
        }
    } else {
        switch (section) {
            case 0: return [self cellForTitle];
            case 1: return [self cellForContent];
            case 2: return [self cellForDate];
            case 3: return [self cellForMapView];
            case 4: return [self cellForLocationAtIndex:indexPath.row];
            case 5: return [self cellForCoordinateAtIndex:indexPath.row];
            default: return nil;
        }
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - TextView Delegate Method 

- (BOOL)enableEnterKeyForTextView:(UITextView *)view
{
    if ([view.text hasSuffix:@"."] || [view.text hasSuffix:@"。"]) {
        return YES;
    }
    if ([view.text hasSuffix:@"?"] || [view.text hasSuffix:@"？"]) {
        return YES;
    }
    if ([view.text hasSuffix:@"!"] || [view.text hasSuffix:@"！"]) {
        return YES;
    }
    if ([view.text hasSuffix:@"~"] || [view.text hasSuffix:@"～"]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{    
    if ([text isEqualToString:@"\n"]) 
    {
        if (![self enableEnterKeyForTextView:textView]) {
            [textView resignFirstResponder];
            // Return FALSE so that the final '\n' character doesn't get added
            return NO;
        } 
    }
    // For any other character return TRUE so that the text gets added to the view
    return YES;
}

#pragma mark - UITableViewCell Styles
#pragma mark - Cell for Content

- (UITableViewCell *)cellForContent
{
    static NSString *cellID = @"ContentCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if (!self.contentField) {
        self.contentField = [[UITextView alloc] initWithFrame:CGRectMake(15, 12, 290, 240)];
        _contentField.backgroundColor = [UIColor tableViewCellBackgroundColor];
        _contentField.delegate = self;
        _contentField.editable = YES;
        _contentField.textColor = [UIColor tableViewCellTextBlueColor];
        [_contentField setReturnKeyType:UIReturnKeyDone];
        [_contentField setFont:[UIFont systemFontOfSize:17.0]];
        _contentField.scrollEnabled = YES;
        
    }
    
    [cell addSubview:self.contentField];
    
    return cell;
}

#pragma mark - Cell for Date

- (UITableViewCell *)cellForDate
{
    static NSString *cellID = @"DateCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    if (!self.dateField) {
        self.dateField = [[UITextField alloc] initWithFrame:CGRectMake(20, 8, 285, 30)];
        _dateField.delegate = self;
        _dateField.textAlignment = UITextAlignmentLeft;
        [_dateField setEnabled:NO];
        _dateField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _dateField.placeholder = @"Date";
        _dateField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _dateField.textColor = [UIColor tableViewCellTextBlueColor];
        [_dateField setReturnKeyType:UIReturnKeyDone];
        [_dateField addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
    }
    [cell addSubview:self.dateField];
    return cell;
}

#pragma mark - Cell for Coordinate

- (UITableViewCell *)cellForCoordinate
{
    static NSString *cellID = @"CoordinateCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    cell.textLabel.textAlignment = UITextAlignmentLeft;
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:17]];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.text = @"Coordinate";
    
    CGPoint point = [[locationInfo objectAtIndex:0] CGPointValue];
    cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"φ:%.4f, λ:%.4f", point.x, point.y];
    return cell;
}

- (UITableViewCell *)cellForCoordinateAtIndex:(NSInteger)index
{
    static NSString *cellID = @"CoordinateCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    cell.textLabel.textAlignment = UITextAlignmentLeft;
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:17]];
    cell.textLabel.textColor = [UIColor blackColor];
    
    cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
    
    switch (index) 
    {
        case 0: {
            CGPoint point = [[locationInfo objectAtIndex:0] CGPointValue];
            cell.textLabel.text = @"From";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"φ:%.4f, λ:%.4f", point.x, point.y];
        } break;
                
        default: {
            CGPoint point = [[locationInfo objectAtIndex:1] CGPointValue];
            cell.textLabel.text = @"To";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"φ:%.4f, λ:%.4f", point.x, point.y];
        } break;
    }
    return cell;
}

#pragma mark - Cell for Location

- (UITableViewCell *)cellForLocation
{
    static NSString *cellID = @"LocationCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.textAlignment = UITextAlignmentLeft;
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:17]];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (!self.locationField) 
    {
        self.locationField = [[UITextField alloc] initWithFrame:CGRectMake(20, 8, 285, 30)];
        _locationField.delegate = self;
        _locationField.textAlignment = UITextAlignmentLeft;
        _locationField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _locationField.placeholder = @"Location";
        _locationField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _locationField.textColor = [UIColor tableViewCellTextBlueColor];
        [_locationField setReturnKeyType:UIReturnKeyDone];
        [_locationField addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
    }
    
    [cell addSubview:self.locationField];
    return cell;
}

- (UITableViewCell *)cellForLocationAtIndex:(NSInteger)index
{
    static NSString *cellID = @"LocationCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.textAlignment = UITextAlignmentLeft;
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:17]];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    switch (index) 
    {
        case 0: {
            if (!self.locationFromField) 
            {
                self.locationFromField = [[UITextField alloc] initWithFrame:CGRectMake(20, 8, 285, 30)];
                _locationFromField.delegate = self;
                _locationFromField.textAlignment = UITextAlignmentLeft;
                _locationFromField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                _locationFromField.placeholder = @"From";
                _locationFromField.textColor = [UIColor tableViewCellTextBlueColor];
                _locationFromField.clearButtonMode = UITextFieldViewModeWhileEditing;
                [_locationFromField setReturnKeyType:UIReturnKeyDone];
                [_locationFromField addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
            }
            
            [cell addSubview:self.locationFromField];
        } break;
            
        default: {
            if (!self.locationToField) {
                self.locationToField = [[UITextField alloc] initWithFrame:CGRectMake(20, 8, 285, 30)];
                _locationToField.delegate = self;
                _locationToField.textAlignment = UITextAlignmentLeft;
                _locationToField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                _locationToField.placeholder = @"To";
                _locationToField.textColor = [UIColor tableViewCellTextBlueColor];
                _locationToField.clearButtonMode = UITextFieldViewModeWhileEditing;
                [_locationToField setReturnKeyType:UIReturnKeyDone];
                [_locationToField addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
            }
            
            [cell addSubview:self.locationToField];
        } break;
    }
    
    return cell;
}

#pragma mark - Cell for Title

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{    
    //if the textfield is empty, the white space is not allowed
    if ([textField.text length] == 0) {
        if ([string isEqualToString:@" "]) {
            return NO;
        }
    }
    return YES;
}

- (void)textFieldFinished:(id)sender {
    [sender resignFirstResponder];
}

- (UITableViewCell *)cellForTitle
{
    static NSString *cellID = @"TitleCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (!self.titleField) {
        self.titleField = [[UITextField alloc] initWithFrame:CGRectMake(20, 8, 285, 30)];
        _titleField.delegate = self;
        _titleField.textAlignment = UITextAlignmentLeft;
        _titleField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _titleField.placeholder = @"Title";
        _titleField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _titleField.textColor = [UIColor tableViewCellTextBlueColor];
        [_titleField setReturnKeyType:UIReturnKeyDone];
        [_titleField addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
    }
    
    [cell addSubview:self.titleField];
    
    return cell;
}

#pragma mark - Cell for Map

- (UITableViewCell *)cellForMapView
{    
    static NSString * cellID = @"MapCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    
    if (!self.mapView) {
        CGFloat cellWidth = self.view.bounds.size.width - 20;
        self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, cellWidth, 240)]; //map height
        [_mapView setDelegate:self];
        _mapView.layer.masksToBounds = YES;
        _mapView.layer.cornerRadius = 10.0;
        _mapView.mapType = MKMapTypeStandard;
        [_mapView setScrollEnabled:NO];
        
        // add a pin using self as the object implementing the MKAnnotation protocol
        switch (self.bookmarkType) 
        {
            case BookmarkLocation: {
                MKPointAnnotation *location = (MKPointAnnotation *)overlayObject;
                [_mapView addAnnotation:location];
                
                MKCoordinateRegion area = MKCoordinateRegionMakeWithDistance(location.coordinate, 200, 200);
                [_mapView setRegion:area animated:YES];
            } break;
                
            case BookmarkPath: {
                MKPolyline *path = (MKPolyline *)overlayObject;
                [_mapView addOverlay:path];
                MKCoordinateRegion area = MKCoordinateRegionForMapRect(path.boundingMapRect);
                [_mapView setRegion:area animated:YES];
            } break;
                
            default: {
                MKPolygon *region = (MKPolygon *)overlayObject;
                [_mapView addOverlay:region];
                MKCoordinateRegion area = MKCoordinateRegionForMapRect(region.boundingMapRect);
                [_mapView setRegion:area animated:YES];
            } break;
        }
    
    }
        
    [cell.contentView addSubview:self.mapView];
    return cell;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) 
    {
        static NSString *locationAnnotationIdentifier = @"LocationPinAnnotationIdentifier";
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)
        [mapView dequeueReusableAnnotationViewWithIdentifier:locationAnnotationIdentifier];
        
        if (!pinView)
        {
            // if an existing pin view was not available, create one
            MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc]
                                                  initWithAnnotation:annotation reuseIdentifier:locationAnnotationIdentifier];
            customPinView.pinColor = MKPinAnnotationColorRed;
            customPinView.animatesDrop = NO;
            customPinView.canShowCallout = YES;

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

#pragma mark - Table View Delegate

- (void)timeWasSelected:(NSDate *)selectedDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss a"];
    _dateField.text = [formatter stringFromDate:selectedDate];
    _dateField.textAlignment = UITextAlignmentCenter;
}

//- (void)timeWasSelected:(NSDate *)

- (void)showTimePickerView
{
    ActionSheetDatePicker *timePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"" datePickerMode:UIDatePickerModeDateAndTime selectedDate:self.objectID target:self action:@selector(timeWasSelected:) origin:self.tableView];
    [timePicker showActionSheetPicker];
}

#pragma mark - Geocoder and Date Picker

- (void)displayError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(),^{
        
        NSString *message;
        switch ([error code])
        {
            case kCLErrorGeocodeFoundNoResult: message = @"kCLErrorGeocodeFoundNoResult";
                break;
            case kCLErrorGeocodeCanceled: message = @"kCLErrorGeocodeCanceled";
                break;
            case kCLErrorGeocodeFoundPartialResult: message = @"kCLErrorGeocodeFoundNoResult";
                break;
            default: message = [error description];
                break;
        }
        
        UIAlertView *alert =  [[UIAlertView alloc] initWithTitle:@"An error occurred."
                                                          message:message
                                                         delegate:nil 
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [alert show];
    });   
}

- (void)locationStringWithAddress:(NSString *)address indexPath:(NSIndexPath *)indexPath
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.bookmarkType != BookmarkPath) 
        {
            _locationField.text = address;
        } 
        else
        {
            switch (indexPath.row) {
                case 0: {
                    _locationFromField.text = address;
                } break;
                    
                default: {
                    _locationToField.text = address;
                } break;
            }
        }
    });
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 5) //Location Geocoding
    {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[[locationInfo objectAtIndex:indexPath.row] CGPointValue].x longitude:[[locationInfo objectAtIndex:indexPath.row] CGPointValue].y];
        //CLLocationCoordinate2D coord = [[locationInfo objectAtIndex:indexPath.row] MKCoordinateValue];
        //CLLocation *location = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
        
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
        {
            if (error)
            {
                NSLog(@"Geocode failed with error: %@", error);
                [self displayError:error];
                return;
            } 
            NSLog(@"%@", placemarks);
            
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSString *address = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self locationStringWithAddress:address indexPath:indexPath];
        }];
    } 
    else if (indexPath.section == 2) //Date Selection
    {
        [self showTimePickerView];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end
