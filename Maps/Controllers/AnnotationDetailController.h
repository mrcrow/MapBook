//
//  DetailWithDeleteViewController.h
//  Maps
//
//  Created by WU Wenzhi on 12-10-24.
//  Copyright (c) 2012年 PolyU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnnotationDetail.h"
#import "MapAnnotation.h"

@interface AnnotationDetailController : UITableViewController

@property (strong, nonatomic) MapAnnotation *detail;

@end
