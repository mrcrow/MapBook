//
//  AddBookmarkViewController.h
//  Maps
//
//  Created by WU Wenzhi on 12-10-16.
//  Copyright (c) 2012年 PolyU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

enum {
    BookmarkLocation = 1,
    BookmarkPath = 2,
    BookmarkRegion = 3,
};
typedef NSInteger BookmarkType;

@protocol AddBookmarkViewControllerDelegate;

@interface AddBookmarkViewController : UITableViewController <MKMapViewDelegate, UITextFieldDelegate, UITextViewDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) id <AddBookmarkViewControllerDelegate> delegate;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)setAnnotation:(id<MKAnnotation>)annot type:(NSInteger)type coordinateInfo:(NSMutableArray *)array locationInfo:(NSArray *)info objectID:(NSDate *)date;
@end

@protocol AddBookmarkViewControllerDelegate

- (void)addBookmarkViewController:(AddBookmarkViewController *)controller addAnnotationToMapView:(id <MKAnnotation>)annotation;
- (void)addBookmarkViewController:(AddBookmarkViewController *)controller rootViewNavigationBarTransform:(BOOL)transform;

@end