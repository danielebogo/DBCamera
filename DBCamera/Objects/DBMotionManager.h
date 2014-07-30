//
//  DBMotionManager.h
//  DBCamera
//
//  Created by iBo on 30/07/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DBMotionManagerRotationHandler)();

@interface DBMotionManager : NSObject
@property (nonatomic, copy) DBMotionManagerRotationHandler motionRotationHandler;

+ (instancetype) sharedManager;
- (void) startMotionHandler;
@end