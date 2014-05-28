//
//  DBCameraBaseCropViewController.h
//  CropImage
//
//  Created by Daniele Bogo on 19/04/14.
//  Copyright (c) 2014 Daniele Bogo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBCameraDelegate.h"

/**
 *  DBCameraBaseCropViewController
 */
@interface DBCameraBaseCropViewController : UIViewController
/**
 *  The source image view
 */
@property (nonatomic, weak) UIImageView *imageView;

/**
 *  The source image
 */
@property (nonatomic, copy) UIImage *sourceImage;

/**
 *  The preview image
 */
@property (nonatomic, copy) UIImage *previewImage;

/**
 *  The crop size
 */
@property (nonatomic, assign) CGSize cropSize;

/**
 *  The crop rect
 */
@property (nonatomic, assign) CGRect cropRect;

/**
 *  The uotuput width, minimum and maximum scale
 */
@property (nonatomic, assign) CGFloat outputWidth, minimumScale, maximumScale;

/**
 *  The crop bound rect
 */
@property (nonatomic, readonly) CGRect cropBoundsInSourceImage;

/**
 *  Enable the crop gestures
 *
 *  @param enable BOOL value to set enable value
 */
- (void) enableGestures:(BOOL)enable;

/**
 *  Set the new crop bounds
 *
 *  @param animated BOOL value to set animated value
 */
- (void) reset:(BOOL)animated;

/**
 *  This method creates the new image
 *
 *  @param transform         The image view transform
 *  @param sourceImage       The source image
 *  @param sourceSize        The source image size
 *  @param sourceOrientation The source image orientation
 *  @param outputWidth       The output width
 *  @param cropRect          The crop rect
 *  @param imageViewSize     The image view size
 *
 *  @return A new CGImageRef used to create a new UIImage
 */
- (CGImageRef) newTransformedImage:(CGAffineTransform)transform sourceImage:(CGImageRef)sourceImage sourceSize:(CGSize)sourceSize
                 sourceOrientation:(UIImageOrientation)sourceOrientation outputWidth:(CGFloat)outputWidth
                          cropRect:(CGRect)cropRect imageViewSize:(CGSize)imageViewSize;
@end