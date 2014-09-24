//
//  DBCameraViewController.h
//  DBCamera
//
//  Created by iBo on 31/01/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBCameraDelegate.h"
#import "UIViewController+UIViewController_FullScreen.h"

@class DBCameraManager;
@class DBCameraView;
@class DBCameraGridView;
@class DBCameraSegueViewController;

/**
 *  DBCameraViewController
 */
@interface DBCameraViewController : UIViewController <DBCameraSegueSettings, DBCameraViewControllerSettings>
/**
 *  An id object compliant with the DBCameraViewControllerDelegate
 */
@property (nonatomic, weak) id <DBCameraViewControllerDelegate> delegate;

/**
 *  An id object compliant with the DBCameraContainerDelegate
 */
@property (nonatomic, weak) id <DBCameraContainerDelegate> containerDelegate;

/**
 *  The camera manager object
 */
@property (nonatomic, strong, readonly) DBCameraManager *cameraManager;

/**
 *  The BOOL value to set if the view controller will have a DBCameraSegueViewController
 */
@property (nonatomic, assign) BOOL useCameraSegue;

/**
 *  The BOOL value to set if it is contained in a DBCameraContainer
 */
@property (nonatomic, assign) BOOL isContained;

/**
 *  The DBCameraView property
 */
@property (nonatomic, strong) DBCameraView *cameraView;

/**
 *  The DBCameraGridView property
 */
@property (nonatomic, strong) DBCameraGridView *cameraGridView;

/**
 *  Set the max resolution for the library selected image
 */
@property (nonatomic, assign) NSUInteger libraryMaxImageSize;

/**
 *  The init class method with a DBCameraViewControllerDelegate
 *
 *  @param delegate The DBCameraViewControllerDelegate
 *
 *  @return A DBCameraViewController
 */
+ (instancetype) initWithDelegate:(id<DBCameraViewControllerDelegate>)delegate;

/**
 *  The init class method
 *
 *  @return A DBCameraViewController
 */
+ (instancetype) init;

/**
 *  The init method with a DBCameraViewControllerDelegate and a custom camera view
 *
 *  @param delegate The DBCameraViewControllerDelegate
 *  @param camera   The custom camera view
 *
 *  @return A DBCameraViewController
 */
- (instancetype) initWithDelegate:(id<DBCameraViewControllerDelegate>)delegate cameraView:(id)camera;
@end
