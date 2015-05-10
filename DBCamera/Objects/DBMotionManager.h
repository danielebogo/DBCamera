//
//  DBMotionManager.h
//  DBCamera
//
//  Created by iBo on 30/07/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  DBMotionManagerRotationHandler handles the current orientation
 */
typedef void (^DBMotionManagerRotationHandler)(UIDeviceOrientation);

/**
 *  DBMotionManager detect the orientation using CoreMotion
 */
@interface DBMotionManager : NSObject
/**
 *  The DBMotionManagerRotationHandler property
 */
@property (nonatomic, copy) DBMotionManagerRotationHandler motionRotationHandler;

/**
 *  The constructor method of
 *
 *  @return the DBMotionManager instancetype
 */
+ (instancetype) sharedManager;

/**
 *  Start to detect the rotation
 */
- (void) startMotionHandler;
@end
