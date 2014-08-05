//
//  DBMotionManager.m
//  DBCamera
//
//  Created by iBo on 30/07/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "DBMotionManager.h"

#import <CoreMotion/CoreMotion.h>

@interface DBMotionManager () {
	CMAccelerometerHandler _motionHandler;
}

@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, assign) UIDeviceOrientation lastOrientation;
@end

@implementation DBMotionManager

- (CMMotionManager *) motionManager
{
    if ( !_motionManager ) {
        _motionManager = [[CMMotionManager alloc] init];
    }
    
    return _motionManager;
}

+ (instancetype) sharedManager
{
    static DBMotionManager *sharedManager = nil;
    static dispatch_once_t predicate = 0;
    
    dispatch_once(&predicate, ^{
        sharedManager = [[DBMotionManager alloc] init];
    });
    
    return sharedManager;
}

- (id) init
{
    self = [super init];
    
    if ( self ) {
        if ( [self.motionManager isAccelerometerAvailable] ) {
            [self.motionManager setAccelerometerUpdateInterval:.2f];
        } else {
            [self deviceOrientationDidChangeTo:UIDeviceOrientationLandscapeRight];
        }
    }
    
    return self;
}

- (void) startMotionHandler
{
    __weak typeof(self) weakSelf = self;
	_motionHandler = ^ (CMAccelerometerData *accelerometerData, NSError *error) {
        typeof(self) selfBlock = weakSelf;
        
		CGFloat xx = accelerometerData.acceleration.x;
		CGFloat yy = -accelerometerData.acceleration.y;
		CGFloat zz = accelerometerData.acceleration.z;
        
		CGFloat device_angle = M_PI / 2.0f - atan2(yy, xx);
		UIDeviceOrientation orientation = UIDeviceOrientationUnknown;
        
		if (device_angle > M_PI)
            device_angle -= 2 * M_PI;
        
		if ((zz < -.60f) || (zz > .60f)) {
			if ( UIDeviceOrientationIsLandscape(selfBlock.lastOrientation) )
				orientation = selfBlock.lastOrientation;
			else
				orientation = UIDeviceOrientationUnknown;
		} else {
			if ( (device_angle > -M_PI_4) && (device_angle < M_PI_4) )
				orientation = UIDeviceOrientationPortrait;
			else if ((device_angle < -M_PI_4) && (device_angle > -3 * M_PI_4))
				orientation = UIDeviceOrientationLandscapeLeft;
			else if ((device_angle > M_PI_4) && (device_angle < 3 * M_PI_4))
				orientation = UIDeviceOrientationLandscapeRight;
			else
				orientation = UIDeviceOrientationPortraitUpsideDown;
		}
        
		if (orientation != selfBlock.lastOrientation) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[selfBlock deviceOrientationDidChangeTo:orientation];
			});
        }
	};
    
	[self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:_motionHandler];
}

- (void) deviceOrientationDidChangeTo:(UIDeviceOrientation)orientation
{
    [self setLastOrientation:orientation];

    if (self.motionRotationHandler) {
        self.motionRotationHandler(self.lastOrientation);
    }
}

@end
