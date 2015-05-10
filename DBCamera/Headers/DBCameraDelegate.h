//
//  DBCameraViewDelegate.h
//  DBCamera
//
//  Created by iBo on 05/02/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
/**
 *  DBCameraView delegate protocol
 */
@class DBCameraGridView;
@class DBCameraViewController;
@protocol DBCameraViewDelegate <NSObject>
@optional
/**
 *  Send to the delegate the CGPoint to set the focus
 *
 *  @param camera The camera view
 *  @param point  The focus CGPoint
 */
- (void) cameraView:(UIView *)camera focusAtPoint:(CGPoint)point;

/**
 *  Send to the delegate the CGPoint to set the expose
 *
 *  @param camera The camera view
 *  @param point  The focus CGPoint
 */
- (void) cameraView:(UIView *)camera exposeAtPoint:(CGPoint)point;

/**
 *  Tells the delegate when the camera start recording
 */
- (void) cameraViewStartRecording;

/**
 *  Tells the delegate when the camera must be closed
 */
- (void) closeCamera;

/**
 *  Tells the delegate when the camera switch front to back (and vice versa)
 */
- (void) switchCamera;

/**
 *  Tells the delegate the status of the flash
 *
 *  @param flashMode The AVCaptureFlashMode of the flash
 */
- (void) triggerFlashForMode:(AVCaptureFlashMode)flashMode;

/**
 *  Trigger action to show / hide the grid
 *
 *  @param camera The grid view
 *  @param show   BOOL value to show the grid
 */
- (void) cameraView:(UIView *)camera showGridView:(BOOL)show;

/**
 *  Tells the delegate when the Library picker must be opened
 */
- (void) openLibrary;

/**
 *  Check if the camera has the Focus
 *
 *  @return BOOL value if the camera has the focus
 */
- (BOOL) cameraViewHasFocus;

/**
 *  Set the capture manager scale
 *
 *  @param scaleNum The scale value for camera manager
 */
- (void) cameraCaptureScale:(CGFloat)scaleNum;

/**
 *  Get the value of max scale
 *
 *  @return The max scale value
 */
- (CGFloat) cameraMaxScale;
@end

/**
 *  DBCameraViewController delegate protocol
 */
@protocol DBCameraViewControllerDelegate <NSObject>
@optional
/**
 *  Tells the delegate when the image is ready to use
 *
 *  @param cameraViewController    The controller object managing the DBCamera interface.
 *  @param image    The captured image
 *  @param metadata The metadata of the image
 */
- (void) camera:(id)cameraViewController didFinishWithImage:(UIImage *)image withMetadata:(NSDictionary *)metadata;

/**
 *  Tells the delegate when the camera must be dismissed
 */
- (void) dismissCamera:(id)cameraViewController;
@end

/**
 *  DBCameraContainer delegate protocol
 */
@protocol DBCameraContainerDelegate <NSObject>
/**
 *  The back action to the previous controller
 *
 *  @param fromController The from controller
 */
- (void) backFromController:(id)fromController;

/**
 *  Switch action between two controllers within the container
 *
 *  @param fromController The controller that will be hide
 *  @param controller     The controller that will be appear
 */
- (void) switchFromController:(id)fromController toController:(id)controller;
@end

/**
 *  DBCameraColletcionController delegate protocol
 */
@protocol DBCameraCollectionControllerDelegate <NSObject>

/**
 *  Tells the delegate the selected NSURL of the Asset
 *
 *  @param collectionView The collection view
 *  @param URL            The NSURL of the Asset
 */
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

/**
 *  DBCameraSegueSettings protocol
 */
@protocol DBCameraSegueSettings <NSObject>
/**
 *  Set if the Camera Segue has a force quad crop mode
 */
@property (nonatomic, assign) BOOL forceQuadCrop;

/**
 *  Set if Camera View Controller will use the camera segue
 */
@property (nonatomic, assign) BOOL useCameraSegue;

/**
 *  Use this to alter the segue view before it is presented.
 */
@property (nonatomic, copy) void (^cameraSegueConfigureBlock)(id segueViewController);
@end

/**
 *  DBCameraViewControllerSettings protocol
 */
@protocol DBCameraViewControllerSettings <NSObject>
/**
 *  Set the tint color of icons and labels
 */
@property (nonatomic, strong) UIColor *tintColor;

/**
 *  Set the tint color of icons and labels for the selected state
 */
@property (nonatomic, strong) UIColor *selectedTintColor;
@end