//
//  MapOverlay.m
//  Maps
//
//  Created by WU Wenzhi on 12-10-12.
//  Copyright (c) 2012年 PolyU. All rights reserved.
//

#import "PathBookmark.h"

@interface PathBookmark ()
@property (nonatomic, strong) NSString *name;
@property CLLocationCoordinate2D theCoordinate;
@end

@implementation PathBookmark
@synthesize name = _name;

@synthesize theCoordinate;

@synthesize path, annotID, position;

@synthesize coordinate;

- (id)initWithPolyline:(MKPolyline *)polyline coordinate:(CLLocationCoordinate2D)coord objectID:(NSString *)string activity:(NSString *)activity position:(NSString *)location
{
    self = [super init];
    if (self) {
        self.path = polyline;
        self.annotID = string;
        self.name = activity;
        self.theCoordinate = coord;
        self.position = location;
    }
    return self;
}

- (NSString *)title
{
    return self.name;
}

- (NSString *)subtitle
{
    return self.position;
}

- (CLLocationCoordinate2D)coordinate
{
    return self.theCoordinate;
}

@end
