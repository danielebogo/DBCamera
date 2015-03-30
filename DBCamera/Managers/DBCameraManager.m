//
//  DBCameraManager.m
//  DBCamera
//
//  Created by iBo on 31/01/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "DBCameraManager.h"

@interface DBCameraManager (AVCaptureFileOutputRecordingDelegate) <AVCaptureFileOutputRecordingDelegate>
@end

@interface DBCameraManager () {
    AVCaptureStillImageOutput *_stillImageOutput;
    CGFloat _maxScale;
}

- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition)position;
- (AVCaptureDevice *) frontCamera;
- (AVCaptureDevice *) backCamera;

@end

@implementation DBCameraManager

#pragma Class methods

+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections {
	AVCaptureConnection *videoConnection = nil;
    for ( AVCaptureConnection *connection in connections ) {
		for ( AVCaptureInputPort *port in [connection inputPorts] ) {
            if ( [port.mediaType isEqual:mediaType] ) {
				videoConnection = connection;
                break;
            }
		}
        if (videoConnection) {
            break;
        }
	}
    
	return videoConnection;
}

#pragma mark - Life cycle

- (id) init
{
    self = [super init];
    if ( self ) {
        _maxScale = 1.0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector( captureSessionDidStartRunning: )
                                                     name:AVCaptureSessionDidStartRunningNotification object:_captureSession];
    }
    
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_captureSession stopRunning];
    
    _captureSession = nil;
    _videoInput = nil;
    _stillImageOutput = nil;
}

- (BOOL) setupSessionWithPreset:(NSString *)sessionPreset error:(NSError **)error
{
    _videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera] error:error];
    
    _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    [_stillImageOutput setOutputSettings:@{ AVVideoCodecKey : AVVideoCodecJPEG }];
    
    _captureSession = [[AVCaptureSession alloc] init];
    if ( [_captureSession canAddInput:_videoInput] )
        [_captureSession addInput:_videoInput];

    if ( [_captureSession canAddOutput:_stillImageOutput] )
        [_captureSession addOutput:_stillImageOutput];
    
    [_captureSession setSessionPreset:sessionPreset];
    
    [self setFlashMode:AVCaptureFlashModeOff];
    
    return YES;
}

- (void) captureSessionDidStartRunning:(NSNotification *)notification
{
    if ( [_delegate respondsToSelector:@selector(captureSessionDidStartRunning)] )
        [_delegate captureSessionDidStartRunning];
}

#pragma mark - Camera action

- (void) startRunning
{
    [_captureSession startRunning];
}

- (void) stopRunning
{
    [_captureSession stopRunning];
}

- (void) captureImageForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    AVCaptureConnection *videoConnection = [DBCameraManager connectionWithMediaType:AVMediaTypeVideo fromConnections:_stillImageOutput.connections];

    if (!videoConnection) {
        NSError *error = [NSError errorWithDomain:@"DBCamera"
                                             code:-1
                                         userInfo:@{
                                                 NSLocalizedFailureReasonErrorKey : @"cameraimage.noconnection"
                                         }];

        if ([_delegate respondsToSelector:@selector(captureImageFailedWithError:)]) {
            [_delegate captureImageFailedWithError:error];
        }

        return;
    }
    
    if ( [videoConnection isVideoOrientationSupported] ) {
        switch (deviceOrientation) {
            case UIDeviceOrientationPortraitUpsideDown:
                [videoConnection setVideoOrientation:AVCaptureVideoOrientationPortraitUpsideDown];
                break;
            
            case UIDeviceOrientationLandscapeLeft:
                [videoConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
                break;
                
            case UIDeviceOrientationLandscapeRight:
                [videoConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
                break;
                
            default:
                [videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
                break;
        }
    }
    
    [videoConnection setVideoScaleAndCropFactor:_maxScale];

    __weak AVCaptureSession *captureSessionBlock = _captureSession;
    __weak id<DBCameraManagerDelegate>delegateBlock = _delegate;
    
    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                  completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
         [captureSessionBlock stopRunning];
         
         if ( imageDataSampleBuffer != NULL ) {
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
             UIImage *image = [[UIImage alloc] initWithData:imageData];
             
             CFDictionaryRef metadata = CMCopyDictionaryOfAttachments(NULL, imageDataSampleBuffer, kCMAttachmentMode_ShouldPropagate);
             NSDictionary *meta = [[NSDictionary alloc] initWithDictionary:(__bridge NSDictionary *)(metadata)];
             CFRelease(metadata);
             
             if ( [delegateBlock respondsToSelector:@selector(captureImageDidFinish:withMetadata:)] )
                 [delegateBlock captureImageDidFinish:image withMetadata:meta];
         } else if ( error ) {
             if ( [delegateBlock respondsToSelector:@selector(captureImageFailedWithError:)] )
                 [delegateBlock captureImageFailedWithError:error];
         }
     }];
}

#pragma mark - Informations

- (void) setCameraMaxScale:(CGFloat)maxScale
{
    _maxScale = maxScale;
}

- (CGFloat) cameraMaxScale
{
    AVCaptureConnection *videoConnection = [DBCameraManager connectionWithMediaType:AVMediaTypeVideo fromConnections:_stillImageOutput.connections];
    return videoConnection.videoMaxScaleAndCropFactor;
}

- (BOOL) cameraToggle
{
    BOOL success = NO;
    
    if ( [self hasMultipleCameras] ) {
        NSError *error;
        AVCaptureDeviceInput *newVideoInput;
        AVCaptureDevicePosition position = _videoInput.device.position;
        
        if ( position == AVCaptureDevicePositionBack )
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontCamera] error:&error];
        else if (position == AVCaptureDevicePositionFront)
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera] error:&error];
        else
            goto bail;
        
        if ( newVideoInput != nil ) {
            [_captureSession beginConfiguration];
            [_captureSession removeInput:_videoInput];
            
            if ( [_captureSession canAddInput:newVideoInput] ) {
                [_captureSession addInput:newVideoInput];
                
                _videoInput = newVideoInput;
            } else
                [_captureSession addInput:_videoInput];

            [_captureSession commitConfiguration];
            
            success = YES;
        } else if ( error ) {
            if ( [_delegate respondsToSelector:@selector(someOtherError:)] )
                [_delegate someOtherError:error];
        }
    }
    
bail:
    return success;
}

- (BOOL) hasMultipleCameras
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 1 ? YES : NO;
}

- (BOOL) hasFlash
{
    return _videoInput.device.hasFlash;
}

- (AVCaptureFlashMode) flashMode
{
    return _videoInput.device.flashMode;
}

- (void) setFlashMode:(AVCaptureFlashMode)flashMode
{
    AVCaptureDevice *device = _videoInput.device;
    if ( [device isFlashModeSupported:flashMode] && device.flashMode != flashMode ) {
        NSError *error;
        if ( [device lockForConfiguration:&error] ) {
            device.flashMode = flashMode;
            [device unlockForConfiguration];
        } else {
            if ( [_delegate respondsToSelector:@selector(acquiringDeviceLockFailedWithError:)] )
                [_delegate acquiringDeviceLockFailedWithError:error];
        }
    }
}

- (BOOL) hasTorch
{
    return _videoInput.device.hasTorch;
}

- (BOOL) hasFocus
{
    AVCaptureDevice *device = _videoInput.device;
    
    return  [device isFocusModeSupported:AVCaptureFocusModeLocked] ||
    [device isFocusModeSupported:AVCaptureFocusModeAutoFocus] ||
    [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus];
}

- (BOOL) hasExposure
{
    AVCaptureDevice *device = _videoInput.device;
    
    return  [device isExposureModeSupported:AVCaptureExposureModeLocked] ||
    [device isExposureModeSupported:AVCaptureExposureModeAutoExpose] ||
    [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure];
}

- (BOOL) hasWhiteBalance
{
    AVCaptureDevice *device = _videoInput.device;
    
    return  [device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeLocked] ||
    [device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance];
}

#pragma mark - Focus & Exposure

- (void) focusAtPoint:(CGPoint)point
{
    AVCaptureDevice *device = _videoInput.device;
    if ( device.isFocusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus] ) {
        NSError *error;
        if ( [device lockForConfiguration:&error] ) {
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        } else {
            if ( [_delegate respondsToSelector:@selector(acquiringDeviceLockFailedWithError:)] )
                [_delegate acquiringDeviceLockFailedWithError:error];
        }
    }
}

- (void) exposureAtPoint:(CGPoint)point
{
    AVCaptureDevice *device = _videoInput.device;
    if ( device.isExposurePointOfInterestSupported && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure] ) {
        NSError *error;
        if ( [device lockForConfiguration:&error] ) {
            device.exposurePointOfInterest = point;
            device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
            [device unlockForConfiguration];
        } else {
            if ( [_delegate respondsToSelector:@selector(acquiringDeviceLockFailedWithError:)] )
                [_delegate acquiringDeviceLockFailedWithError:error];
        }
    }
}

- (CGPoint) convertToPointOfInterestFrom:(CGRect)frame coordinates:(CGPoint)viewCoordinates layer:(AVCaptureVideoPreviewLayer *)layer
{
    CGPoint pointOfInterest = (CGPoint){ 0.5f, 0.5f };
    CGSize frameSize = frame.size;
    
    AVCaptureVideoPreviewLayer *videoPreviewLayer = layer;
    
    if ( [[videoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResize] )
        pointOfInterest = (CGPoint){ viewCoordinates.y / frameSize.height, 1.0f - (viewCoordinates.x / frameSize.width) };
    else {
        CGRect cleanAperture;
        for (AVCaptureInputPort *port in self.videoInput.ports) {
            if ([port mediaType] == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;
                
                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = 0.5f;
                CGFloat yc = 0.5f;
                
                if ( [[videoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspect] ) {
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
                        if (point.x >= blackBar && point.x <= blackBar + x2) {
                            xc = point.y / y2;
                            yc = 1.0f - ((point.x - blackBar) / x2);
                        }
                    } else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
                        if (point.y >= blackBar && point.y <= blackBar + y2) {
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.0f - (point.x / x2);
                        }
                    }
                } else if ([[videoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.0f)) / y2;
                        yc = (frameSize.width - point.x) / frameSize.width;
                    } else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.0f - ((point.x + ((x2 - frameSize.width) / 2)) / x2);
                        xc = point.y / frameSize.height;
                    }
                }
                
                pointOfInterest = (CGPoint){ xc, yc };
                break;
            }
        }
    }
    
    return pointOfInterest;
}

#pragma mark - Property Override

- (NSUInteger) cameraCount
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

- (AVCaptureTorchMode) torchMode
{
    return _videoInput.device.torchMode;
}

- (void) setTorchMode:(AVCaptureTorchMode)torchMode
{
    AVCaptureDevice *device = _videoInput.device;
    if ( [device isTorchModeSupported:torchMode] && device.torchMode != torchMode ) {
        NSError *error;
        if ( [device lockForConfiguration:&error] ) {
            device.torchMode = torchMode;
            [device unlockForConfiguration];
        } else {
            if ( [_delegate respondsToSelector:@selector(acquiringDeviceLockFailedWithError:)] )
                [_delegate acquiringDeviceLockFailedWithError:error];
        }
    }
}

- (AVCaptureFocusMode) focusMode
{
    return _videoInput.device.focusMode;
}

- (void) setFocusMode:(AVCaptureFocusMode)focusMode
{
    AVCaptureDevice *device = _videoInput.device;
    if ([device isFocusModeSupported:focusMode] && device.focusMode != focusMode) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.focusMode = focusMode;
            [device unlockForConfiguration];
        } else {
            if ( [_delegate respondsToSelector:@selector(acquiringDeviceLockFailedWithError:)] )
                [_delegate acquiringDeviceLockFailedWithError:error];
        }
    }
}

- (AVCaptureExposureMode) exposureMode
{
    return _videoInput.device.exposureMode;
}

- (void) setExposureMode:(AVCaptureExposureMode)exposureMode
{
    if ( exposureMode == AVCaptureExposureModeAutoExpose )
        exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    
    AVCaptureDevice *device = _videoInput.device;
    if ( [device isExposureModeSupported:exposureMode] && device.exposureMode != exposureMode ) {
        NSError *error;
        if ( [device lockForConfiguration:&error] ) {
            device.exposureMode = exposureMode;
            [device unlockForConfiguration];
        } else {
            if ( [_delegate respondsToSelector:@selector(acquiringDeviceLockFailedWithError:)] )
                [_delegate acquiringDeviceLockFailedWithError:error];
        }
    }
}

- (AVCaptureWhiteBalanceMode) whiteBalanceMode
{
    return _videoInput.device.whiteBalanceMode;
}

- (void) setWhiteBalanceMode:(AVCaptureWhiteBalanceMode)whiteBalanceMode
{
    if ( whiteBalanceMode == AVCaptureWhiteBalanceModeAutoWhiteBalance )
        whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
    
    AVCaptureDevice *device = _videoInput.device;
    if ( [device isWhiteBalanceModeSupported:whiteBalanceMode] && device.whiteBalanceMode != whiteBalanceMode ) {
        NSError *error;
        if ( [device lockForConfiguration:&error] ) {
            device.whiteBalanceMode = whiteBalanceMode;
            [device unlockForConfiguration];
        } else {
            if ( [_delegate respondsToSelector:@selector(acquiringDeviceLockFailedWithError:)] )
                [_delegate acquiringDeviceLockFailedWithError:error];
        }
    }
}

#pragma mark - Private Methods

- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition)position
{
    __block AVCaptureDevice *deviceBlock = nil;
    
    [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] enumerateObjectsUsingBlock:^( AVCaptureDevice *device, NSUInteger idx, BOOL *stop ) {
        if ( [device position] == position ) {
            deviceBlock = device;
            *stop = YES;
        }
    }];
    
    return deviceBlock;
    
//    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
//    for ( AVCaptureDevice *device in devices ) {
//        if ( [device position] == position )
//            return device;
//    }
//    
//    return nil;
}

- (AVCaptureDevice *) frontCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

- (AVCaptureDevice *)backCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

@end
