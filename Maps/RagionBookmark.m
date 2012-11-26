//
//  BookmarkRagion.m
//  Maps
//
//  Created by WU Wenzhi on 12-10-14.
//  Copyright (c) 2012年 PolyU. All rights reserved.
//

#import "RegionBookmark.h"

@interface RegionBookmark ()
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *locate;
@end

@implementation RegionBookmark

@synthesize name = _name;
@synthesize locate = _locate;
@synthesize region, annotID;

@synthesize coordinate;

- (id)initWithPolygon:(MKPolygon *)polygon objectID:(NSString *)string activity:(NSString *)activity location:(NSString *)location
{
    self = [super init];
    if (self) {
        self.region = polygon;
        self.annotID = string;
        self.name = activity;
        self.locate = location;
    }
    return self;
}

- (NSString *)title
{
    return self.name;
}

- (NSString *)subtitle
{
    return self.locate;
}

- (CLLocationCoordinate2D)coordinate
{
    return self.region.coordinate;
}

@end
