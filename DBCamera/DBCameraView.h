//
//  DBCameraView.h
//  DBCamera
//
//  Created by iBo on 31/01/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "DBCameraDelegate.h"

@interface DBCameraView : UIView
@property (nonatomic, weak) id <DBCameraViewDelegate> delegate;
@property (nonatomic, strong, readonly) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong, readonly) UIView *stripe;
@property (nonatomic, strong, readonly) UITapGestureRecognizer *singleTap, *doubleTap;
@property (nonatomic, strong, readonly) UIPinchGestureRecognizer *pinch;
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *panGestureRecognizer;

+ (id) initWithFrame:(CGRect)frame;
+ (DBCameraView *) initWithCaptureSession:(AVCaptureSession *)captureSession;

- (void) defaultInterface;
- (void) drawFocusBoxAtPointOfInterest:(CGPoint)point andRemove:(BOOL)remove;
- (void) drawExposeBoxAtPointOfInterest:(CGPoint)point andRemove:(BOOL)remove;
- (void) draw:(CALayer *)layer atPointOfInterest:(CGPoint)point andRemove:(BOOL)remove;
- (void) pinchCameraViewWithScalNum:(CGFloat)scale;

@end