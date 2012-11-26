//
//  BookmarkRagion.h
//  Maps
//
//  Created by WU Wenzhi on 12-10-14.
//  Copyright (c) 2012年 PolyU. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface RegionBookmark : NSObject <MKAnnotation>

@property (nonatomic, strong) MKPolygon *region;
@property (nonatomic, strong) NSString *annotID;

- (id)initWithPolygon:(MKPolygon *)polygon objectID:(NSString *)string activity:(NSString *)activity location:(NSString *)location;


@end
