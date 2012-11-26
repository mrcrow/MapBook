//
//  OverlayDetailViewController.m
//  Maps
//
//  Created by WU Wenzhi on 12-10-15.
//  Copyright (c) 2012年 PolyU. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "BookmarkDetailController.h"
#import "ColorExtention.h"

@interface BookmarkDetailController ()
@property (strong, nonatomic) MKMapView *mapView;
@property                     NSInteger bookmarkType;
@end

@implementation BookmarkDetailController
@synthesize object = _object;

@synthesize mapView = _mapView;
@synthesize bookmarkType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)setObject:(AnnotationDetail *)object
{
    if (_object != object) {
        _object = object;
        [self.tableView reloadData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setObject:nil];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // Configure the cell...
    cell.textLabel.text = self.object.title;
    cell.detailTextLabel.text = self.object.story;
    return cell;
}

#pragma mark - TableViewCell Styles

/*
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
        switch (self.bookmarkType) {
            case 1: {
                MKPointAnnotation *location = (MKPointAnnotation *)overlayObject;
                [_mapView addAnnotation:location];
                
                MKCoordinateRegion area = MKCoordinateRegionMakeWithDistance(location.coordinate, 200, 200);
                [_mapView setRegion:area animated:YES];
            } break;
                
            case 2: {
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
}*/

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
