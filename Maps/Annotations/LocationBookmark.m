//
//  MapAnnotation.m
//  Maps
//
//  Created by WU Wenzhi on 12-10-7.
//  Copyright (c) 2012年 PolyU. All rights reserved.
//

#import "LocationBookmark.h"

@interface LocationBookmark ()
@property CLLocationCoordinate2D annotationCoordinate;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *locate;
@end

@implementation LocationBookmark
@synthesize name = _name;
@synthesize locate = _locate;

@synthesize annotationCoordinate, annotID;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord objectID:(NSString *)string activity:(NSString *)activity location:(NSString *)location
{
    if (self = [super init]) {
        self.annotationCoordinate = coord;
        self.annotID = string;
        self.name = activity;
        self.locate = location;
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate
{
    return annotationCoordinate;
}

- (NSString *)title
{
    return self.name;
}

- (NSString *)subtitle
{
    return self.locate;
}

@end
