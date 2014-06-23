//
//  DBCameraLibraryViewController.h
//  DBCamera
//
//  Created by iBo on 06/03/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBCameraDelegate.h"

@class DBCameraSegueViewController;

/**
 *  DBCameraLibraryViewController
 */
@interface DBCameraLibraryViewController : UIViewController <DBCameraSegueSettings, DBCameraViewControllerSettings>
/**
 *  An id object compliant with the DBCameraContainerDelegate
 */
@property (nonatomic, weak) id <DBCameraContainerDelegate> containerDelegate;

/**
 *  An id object compliant with the DBCameraViewControllerDelegate
 */
@property (nonatomic, weak) id <DBCameraViewControllerDelegate> delegate;

/**
 *  Set the max resolution for the selected image
 */
@property (nonatomic, assign) NSUInteger libraryMaxImageSize;

/**
 *  The init method with an DBCameraContainerDelegate object
 *
 *  @param delegate The DBCameraContainerDelegate object
 *
 *  @return A DBCameraLibraryViewController
 */
- (id) initWithDelegate:(id<DBCameraContainerDelegate>)delegate;
@end