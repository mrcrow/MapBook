//
//  MapAnnotation.h
//  Maps
//
//  Created by WU Wenzhi on 12-10-7.
//  Copyright (c) 2012年 PolyU. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface LocationBookmark : NSObject <MKAnnotation>

@property (nonatomic, strong) NSString *annotID;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord objectID:(NSString *)string activity:(NSString *)activity location:(NSString *)location;

@end
