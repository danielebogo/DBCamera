//
//  DBCameraContainerViewController.h
//  DBCamera
//
//  Created by iBo on 06/03/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBCameraDelegate.h"
#import "UIViewController+UIViewController_FullScreen.h"

@class DBCameraView, DBCameraViewController, DBCameraConfiguration;

/**
 *  The camera settings block
 *
 *  @param cameraView The DBCameraView get from block hanlder
 *  @param container  The container get from block hanlder
 */
typedef void(^CameraSettingsBlock)(DBCameraView *cameraView, id container);

/**
 *  DBCameraContainerViewController
 */
@interface DBCameraContainerViewController : UIViewController <DBCameraViewControllerSettings>
/**
 *  An id object compliant with DBCameraViewControllerDelegate
 */
@property (nonatomic, weak) id <DBCameraViewControllerDelegate> delegate;

/**
 *  A DBCameraViewController that can be set.
 */
@property (nonatomic, strong) DBCameraViewController *cameraViewController;

/**
 *  Contains additional configuration for camera controllers
 */
@property (nonatomic, strong) DBCameraConfiguration *cameraConfiguration;

/**
 *  The init method with a DBCameraViewControllerDelegate
 *
 *  @param delegate The DBCameraViewControllerDelegate
 *
 *  @return A DBCameraContainerViewController
 */
- (instancetype) initWithDelegate:(id<DBCameraViewControllerDelegate>)delegate;

/**
 *  The init method with a DBCameraViewControllerDelegate and a CameraSettingsBlock
 *
 *  @param delegate The DBCameraViewControllerDelegate
 *  @param block    The CameraSettingsBlock
 *
 *  @return DBCameraContainerViewController
 */
- (instancetype) initWithDelegate:(id<DBCameraViewControllerDelegate>)delegate
              cameraSettingsBlock:(CameraSettingsBlock)block;

/**
 *  The init method with a DBCameraViewControllerDelegate and a CameraConfiguration
 *
 *  @param delegate             The DBCameraViewControllerDelegate
 *  @param cameraConfiguration  The CameraConfiguration containing customization for controllers
 *
 *  @return DBCameraContainerViewController
 */
- (instancetype) initWithDelegate:(id<DBCameraViewControllerDelegate>)delegate
              cameraConfiguration:(DBCameraConfiguration *)cameraConfiguration;

/**
 *  The init method with a DBCameraViewControllerDelegate and a CameraConfiguration
 *
 *  @param delegate             The DBCameraViewControllerDelegate
 *  @param cameraConfiguration  The CameraConfiguration containing customization for controllers
 *  @param block                The CameraSettingsBlock
 *
 *  @return DBCameraContainerViewController
 */
- (instancetype) initWithDelegate:(id<DBCameraViewControllerDelegate>)delegate
              cameraConfiguration:(DBCameraConfiguration *)cameraConfiguration
              cameraSettingsBlock:(CameraSettingsBlock)block;
@end