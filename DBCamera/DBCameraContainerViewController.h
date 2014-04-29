//
//  DBCameraContainerViewController.h
//  DBCamera
//
//  Created by iBo on 06/03/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBCameraDelegate.h"

@class DBCameraView;
@class DBCameraViewController;

typedef void(^CameraSettingsBlock)(DBCameraView *cameraView);

@interface DBCameraContainerViewController : UIViewController
@property (nonatomic, weak) id <DBCameraViewControllerDelegate> delegate;
@property (nonatomic, strong) DBCameraViewController *cameraViewController;

- (id) initWithDelegate:(id<DBCameraViewControllerDelegate>)delegate;
- (id) initWithDelegate:(id<DBCameraViewControllerDelegate>)delegate cameraSettingsBlock:(CameraSettingsBlock)block;
@end