//
//  DBCameraImageVIew.h
//  DBCamera
//
//  Created by iBo on 17/02/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBCameraImageView : UIImageView
@property (nonatomic, assign) CGPoint defaultCenter;
@property (nonatomic, assign, getter = isGesturesEnabled) BOOL gesturesEnabled;

- (void) resetPosition;

@end