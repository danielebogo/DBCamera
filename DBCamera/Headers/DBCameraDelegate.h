//
//  DBCameraViewDelegate.h
//  DBCamera
//
//  Created by iBo on 05/02/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
/**
 *  DBCameraView delegate protocol
 */
@protocol DBCameraViewDelegate <NSObject>
@optional

- (void) cameraView:(UIView *)camera focusAtPoint:(CGPoint)point;
- (void) cameraView:(UIView *)camera exposeAtPoint:(CGPoint)point;
- (void) cameraViewStartRecording;
- (void) closeCamera;
- (void) switchCamera;
- (void) triggerFlashForMode:(AVCaptureFlashMode)flashMode;
- (void) cameraView:(UIView *)camera showGridView:(BOOL)show;
- (void) openLibrary;
- (void) cameraCaptureScale:(CGFloat)scaleNum;
- (BOOL) cameraViewHasFocus;
- (CGFloat) cameraMaxScale;
@end

/**
 *  DBCameraViewController delegate protocol
 */
@protocol DBCameraViewControllerDelegate <NSObject>
@optional
- (void) captureImageDidFinish:(UIImage *)image withMetadata:(NSDictionary *)metadata;
- (void) dismissCamera;
@end

/**
 *  DBCameraContainer delegate protocol
 */
@protocol DBCameraContainerDelegate <NSObject>
- (void) backFromController:(id)fromController;
- (void) switchFromController:(id)fromController toController:(id)controller;
@end

/**
 *  DBCameraColletcionController delegate protocol
 */
@protocol DBCameraCollectionControllerDelegate <NSObject>
- (void) collectionView:(UICollectionView *)collectionView itemURL:(NSURL *)URL;
@end

/**
 *  DBCameraCrop protocol
 */
@protocol DBCameraCropRect
@required
/**
 *  Add cropRect for the frameView.
 */
@property (nonatomic, assign) CGRect cropRect;
@end