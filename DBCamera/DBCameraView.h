//
//  DBCameraView.h
//  DBCamera
//
//  Created by iBo on 31/01/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol DBCameraViewDelegate;
@interface DBCameraView : UIView
@property (nonatomic, weak) id <DBCameraViewDelegate> delegate;
@property (nonatomic, strong, readonly) AVCaptureVideoPreviewLayer *previewLayer;

- (id) initWithCaptureSession:(AVCaptureSession *)captureSession;
- (void) drawFocusBoxAtPointOfInterest:(CGPoint)point andRemove:(BOOL)remove;
- (void) drawExposeBoxAtPointOfInterest:(CGPoint)point andRemove:(BOOL)remove;

@end

@protocol DBCameraViewDelegate <NSObject>
@optional
- (void) cameraView:(DBCameraView *)camera focusAtPoint:(CGPoint)point;
- (void) cameraView:(DBCameraView *)camera exposeAtPoint:(CGPoint)point;
- (void) cameraViewStartRecording;
@end