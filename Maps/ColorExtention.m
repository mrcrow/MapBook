//
//  UIColor+ColorExtention.m
//  Maps
//
//  Created by WU Wenzhi on 12-11-2.
//  Copyright (c) 2012年 PolyU. All rights reserved.
//

#import "ColorExtention.h"

@implementation UIColor (ColorExtention)

+ (UIColor *)tableViewCellTextBlueColor {
    return [UIColor colorWithRed:81.0/255.0 green:102.0/255.0 blue:145.0/255.0 alpha:1.0];
}

+ (UIColor *)tableViewCellBackgroundColor {
    return [UIColor colorWithRed:247.0/255 green:247.0/255 blue:247.0/255 alpha:1.0];
}

+ (UIColor *)pathBookmarkFillColor {
    return [[UIColor colorWithRed:10/255.0 green:140/255.0 blue:15/255 alpha:1.0] colorWithAlphaComponent:0.9];
}

+ (UIColor *)pathBookmarkStrokeColor {
    return [[UIColor colorWithRed:10/255.0 green:140/255.0 blue:15/255 alpha:1.0] colorWithAlphaComponent:0.8];
}

+ (UIColor *)regionBookmarkFillColor {
    return [[UIColor purpleColor] colorWithAlphaComponent:0.4];
}

+ (UIColor *)regionBookmarkStrokeColor {
    return [[UIColor purpleColor] colorWithAlphaComponent:0.8];
}

@end
