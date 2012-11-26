//
//  MapAnnotation.h
//  Maps
//
//  Created by WU Wenzhi on 12-11-8.
//  Copyright (c) 2012年 PolyU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AnnotationDetail;

@interface MapAnnotation : NSManagedObject

@property (nonatomic, retain) NSString * activity;
@property (nonatomic, retain) NSString * annoID;
@property (nonatomic, retain) NSNumber * annoType;
@property (nonatomic, retain) NSString * day;
@property (nonatomic, retain) NSString * locationName;
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSData * coordinatePoints;
@property (nonatomic, retain) AnnotationDetail *detail;

@end
