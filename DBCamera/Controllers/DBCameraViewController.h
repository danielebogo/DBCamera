//
//  DBCameraViewController.h
//  DBCamera
//
//  Created by iBo on 31/01/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBCameraDelegate.h"

@class DBCameraView;
@class DBCameraGridView;
@interface DBCameraViewController : UIViewController
@property (nonatomic, weak) id <DBCameraViewControllerDelegate> delegate;
@property (nonatomic, weak) id <DBCameraContainerDelegate> containerDelegate;
@property (nonatomic, assign) BOOL useCameraSegue;
@property (nonatomic, strong) DBCameraView *cameraView;
@property (nonatomic, strong) DBCameraGridView *cameraGridView;

+ (DBCameraViewController *) initWithDelegate:(id<DBCameraViewControllerDelegate>)delegate;
+ (DBCameraViewController *) init;

- (id) initWithDelegate:(id<DBCameraViewControllerDelegate>)delegate cameraView:(id)camera;
@end