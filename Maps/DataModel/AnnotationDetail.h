//
//  AnnotationDetail.h
//  Maps
//
//  Created by WU Wenzhi on 12-11-8.
//  Copyright (c) 2012年 PolyU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MapAnnotation;

@interface AnnotationDetail : NSManagedObject

@property (nonatomic, retain) NSData * locationPoint;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSString * locationString;
@property (nonatomic, retain) NSString * story;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) MapAnnotation *info;

@end
