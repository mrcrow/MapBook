//
//  MapOverlay.h
//  Maps
//
//  Created by WU Wenzhi on 12-10-12.
//  Copyright (c) 2012年 PolyU. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface PathBookmark : NSObject <MKAnnotation>

@property (nonatomic, strong) MKPolyline *path;
@property (nonatomic, strong) NSString *annotID;
@property (nonatomic, strong) NSString *position;

- (id)initWithPolyline:(MKPolyline *)polyline coordinate:(CLLocationCoordinate2D)coord objectID:(NSString *)string activity:(NSString *)activity position:(NSString *)location;

@end
