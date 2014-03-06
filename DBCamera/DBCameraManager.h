//
//  DBCameraManager.h
//  DBCamera
//
//  Created by iBo on 31/01/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol DBCameraManagerDelegate;
@interface DBCameraManager : NSObject
@property (nonatomic, weak) id <DBCameraManagerDelegate> delegate;
@property (nonatomic, readonly, strong) AVCaptureSession *captureSession;
@property (nonatomic, readonly, strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic, assign) AVCaptureFlashMode flashMode;
@property (nonatomic, assign) AVCaptureTorchMode torchMode;
@property (nonatomic, assign) AVCaptureFocusMode focusMode;
@property (nonatomic, assign) AVCaptureExposureMode exposureMode;
@property (nonatomic, assign) AVCaptureWhiteBalanceMode whiteBalanceMode;
@property (nonatomic, assign, readonly) NSUInteger cameraCount;

- (void) setCameraMaxScale:(CGFloat)maxScale;
- (CGFloat) cameraMaxScale;
- (BOOL) cameraToggle;
- (BOOL) hasMultipleCameras;
- (BOOL) hasFlash;
- (BOOL) hasTorch;
- (BOOL) hasFocus;
- (BOOL) hasExposure;
- (BOOL) hasWhiteBalance;

- (BOOL) setupSessionWithPreset:(NSString *)sessionPreset error:(NSError **)error;

- (void) startRunning;
- (void) stopRunning;
- (void) captureImageForDeviceOrientation:(UIDeviceOrientation)deviceOrientation;

- (void) focusAtPoint:(CGPoint)point;
- (void) exposureAtPoint:(CGPoint)point;
- (CGPoint) convertToPointOfInterestFrom:(CGRect)frame coordinates:(CGPoint)viewCoordinates layer:(AVCaptureVideoPreviewLayer *)layer;

@end

@protocol DBCameraManagerDelegate <NSObject>
@optional
- (void) captureImageDidFinish:(UIImage *)image withMetadata:(NSDictionary *)metadata;
- (void) captureImageFailedWithError:(NSError *)error;
- (void) someOtherError:(NSError *)error;
- (void) acquiringDeviceLockFailedWithError:(NSError *)error;
- (void) captureSessionDidStartRunning;
@end