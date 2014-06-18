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
/**
 *  The object manager for the DBCamera
 */
@interface DBCameraManager : NSObject
/**
 *  The DBCameraManagerDelegate object
 */
@property (nonatomic, weak) id <DBCameraManagerDelegate> delegate;

/**
 *  The DBCamera capture session
 */
@property (nonatomic, readonly, strong) AVCaptureSession *captureSession;

/**
 *  The video input of the capture session
 */
@property (nonatomic, readonly, strong) AVCaptureDeviceInput *videoInput;

/**
 *  The DBCamera flash mode
 */
@property (nonatomic, assign) AVCaptureFlashMode flashMode;

/**
 *  The DBCamera torch mode
 */
@property (nonatomic, assign) AVCaptureTorchMode torchMode;

/**
 *  The DBCamera focus mode
 */
@property (nonatomic, assign) AVCaptureFocusMode focusMode;

/**
 *  The DBCamera exposure mode
 */
@property (nonatomic, assign) AVCaptureExposureMode exposureMode;

/**
 *  The DBCamera white balance mode
 */
@property (nonatomic, assign) AVCaptureWhiteBalanceMode whiteBalanceMode;

/**
 *  The DBCamera camera count
 */
@property (nonatomic, assign, readonly) NSUInteger cameraCount;

/**
 *  Set the camera max scale
 *
 *  @param maxScale The max scale value
 */
- (void) setCameraMaxScale:(CGFloat)maxScale;

/**
 *  Get the camera max scale
 *
 *  @return The max scale value
 */
- (CGFloat) cameraMaxScale;

/**
 *  Switch between front and rear camera
 *
 *  @return BOOL value if the camera is changed
 */
- (BOOL) cameraToggle;

/**
 *  Check if the device has multiple cameras
 *
 *  @return BOOL value indicates if the device has multiple cameras
 */
- (BOOL) hasMultipleCameras;

/**
 *  Check if the device can use the flash mode
 *
 *  @return BOOL value indicates if the device can use the flash mode
 */
- (BOOL) hasFlash;

/**
 *  Check if the device can use the torch mode
 *
 *  @return BOOL value indicates if the device can use the torch mode
 */
- (BOOL) hasTorch;

/**
 *  Check if the device can use the focus mode
 *
 *  @return BOOL value indicates if the device can use the focus mode
 */
- (BOOL) hasFocus;

/**
 *  Check if the device can use the exposure mode
 *
 *  @return BOOL value indicates if the device can use the exposure mode
 */
- (BOOL) hasExposure;

/**
 *  Check if the device can use the white balance mode
 *
 *  @return BOOL value indicates if the device can use the white balance mode
 */
- (BOOL) hasWhiteBalance;

/**
 *  Set the session for the DBCamera
 *
 *  @param sessionPreset The session preset
 *  @param error         The error used by the device input init
 *
 *  @return BOOL value indicates if the setup is ok
 */
- (BOOL) setupSessionWithPreset:(NSString *)sessionPreset error:(NSError **)error;

/**
 *  Start recording
 */
- (void) startRunning;

/**
 *  Stop recording
 */
- (void) stopRunning;

/**
 *  Set the capture image orientation
 *
 *  @param deviceOrientation The device orientation
 */
- (void) captureImageForDeviceOrientation:(UIDeviceOrientation)deviceOrientation;

/**
 *  Set the focus with a CGPoint
 *
 *  @param point The CGPoint for the focus
 */
- (void) focusAtPoint:(CGPoint)point;

/**
 *  Set the exposure with a CGPoint
 *
 *  @param point The CGPoint for the exposure
 */
- (void) exposureAtPoint:(CGPoint)point;

/**
 *  Convert the touch in point to use for the focus or exposure
 *
 *  @param frame           The target frame
 *  @param viewCoordinates The touch coordinates
 *  @param layer           The used AVCaptureVideoPreviewLayer
 *
 *  @return Return the converted CGPoint
 */
- (CGPoint) convertToPointOfInterestFrom:(CGRect)frame coordinates:(CGPoint)viewCoordinates layer:(AVCaptureVideoPreviewLayer *)layer;
@end

/**
 *  The DBCameraManager protocol
 */
@protocol DBCameraManagerDelegate <NSObject>
@optional
/**
 *  This method indicates when the capture session has captured an image
 *
 *  @param image    The captured image
 *  @param metadata The metadata of the image
 */
- (void) captureImageDidFinish:(UIImage *)image withMetadata:(NSDictionary *)metadata;

/**
 *  This method indicates when the capture session has an error
 *
 *  @param error The error of the capture session
 */
- (void) captureImageFailedWithError:(NSError *)error;

/**
 *  This method indicates an error during the toggle action of the camera
 *
 *  @param error The error
 */
- (void) someOtherError:(NSError *)error;

/**
 *  During the requests exclusive access to the device’s hardware properties, this method indicates if a lock cannot be acquired
 *
 *  @param error The error
 */
- (void) acquiringDeviceLockFailedWithError:(NSError *)error;

/**
 *  This method indicates when the capture session did start
 */
- (void) captureSessionDidStartRunning;
@end