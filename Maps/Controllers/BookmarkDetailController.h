//
//  OverlayDetailViewController.h
//  Maps
//
//  Created by WU Wenzhi on 12-10-15.
//  Copyright (c) 2012年 PolyU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AnnotationDetail.h"
#import "MapAnnotation.h"

@interface BookmarkDetailController : UITableViewController <MKMapViewDelegate>

@property (strong, nonatomic) MapAnnotation *detail;

@end
