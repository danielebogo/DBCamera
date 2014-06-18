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

/**
 *  The view class that contains the UI of the camera. Extend this class if you want to create a custom camera view.
 */
@interface DBCameraView : UIView <DBCameraViewControllerSettings>
/**
 *  The DBCameraViewDelegate object
 */
@property (nonatomic, weak) id <DBCameraViewDelegate> delegate;

/**
 *  The button to open the Library
 */
@property (nonatomic, strong) UIButton *photoLibraryButton;

/**
 *  The button to shot with the camera
 */
@property (nonatomic, strong) UIButton *triggerButton;

/**
 *  The button to close
 */
@property (nonatomic, strong) UIButton *closeButton;

/**
 *  The button to display the grid
 */
@property (nonatomic, strong) UIButton *gridButton;

/**
 *  The button to switch the camera
 */
@property (nonatomic, strong) UIButton *cameraButton;

/**
 *  The button to open/close the flash mode
 */
@property (nonatomic, strong) UIButton *flashButton;

/**
 *  The camera preview layer
 */
@property (nonatomic, strong, readonly) AVCaptureVideoPreviewLayer *previewLayer;

/**
 *  Single tap gesture recognizes the focus action
 */
@property (nonatomic, strong, readonly) UITapGestureRecognizer *singleTap;

/**
 *  The double tap gesture recognizes the exposure action
 */
@property (nonatomic, strong, readonly) UITapGestureRecognizer *doubleTap;

/**
 *  The pan gesture recognizes the pan movement for the focus action
 */
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *panGestureRecognizer;

/**
 *  The pinch gesture recognizes the pinch to zoom action
 */
@property (nonatomic, strong) UIPinchGestureRecognizer *pinch;

/**
 *  Class method to create the view with a frame
 *
 *  @param frame The frame of the view
 *
 *  @return Return a DBCameraView instance
 */
+ (id) initWithFrame:(CGRect)frame;

/**
 *  Class method to create the view with a AVCaptureSession
 *
 *  @param captureSession The AVCAptureSession to create the instance
 *
 *  @return Return a DBCameraView instance
 */
+ (DBCameraView *) initWithCaptureSession:(AVCaptureSession *)captureSession;

/**
 *  Create the default interface
 */
- (void) defaultInterface;

/**
 *  Draw and show the focus layer
 *
 *  @param point  The CGPoint of the focus
 *  @param remove If the value is YES, the layer will be removed at the end of the animation
 */
- (void) drawFocusBoxAtPointOfInterest:(CGPoint)point andRemove:(BOOL)remove;

/**
 *  Draw and show the exposure layer
 *
 *  @param point  The CGPoint of the exposure
 *  @param remove If the value is YES, the layer will be removed at the end of the animation
 */
- (void) drawExposeBoxAtPointOfInterest:(CGPoint)point andRemove:(BOOL)remove;

/**
 *  Draw/Show/Animate the target layer
 *
 *  @param layer  The target layer
 *  @param point  The CGPoint of interest
 *  @param remove If the value is YES, the layer will be removed at the end of the animation
 */
- (void) draw:(CALayer *)layer atPointOfInterest:(CGPoint)point andRemove:(BOOL)remove;

/**
 *  The scale value for the zoom action
 *
 *  @param scale The scale value
 */
- (void) pinchCameraViewWithScalNum:(CGFloat)scale;
@end