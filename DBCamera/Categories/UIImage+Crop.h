//
//  UIImage+Crop.h
//  DBCamera
//
//  Created by iBo on 11/02/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  UIImage Crop category
 */
@interface UIImage(Crop)
/**
 *  Create an UIImage from a UIView
 *
 *  @param view The view you want to use
 *
 *  @return an UIImage from the used UIView
 */
+ (UIImage *) screenshotFromView:(UIView *)view;

/**
 *  Crop the UIImage inside a CGRect
 *
 *  @param cropRect the CGRect that define the crop bounds
 *
 *  @return the new UIImage
 */
- (UIImage *) croppedImage:(CGRect)cropRect;

/**
 *  Rotate the UIImgae to the right position
 *
 *  @return the rotated UIImage
 */
- (UIImage *) rotateUIImage;

/**
 *  Create an UIImage with round bounds
 *
 *  @param image  the UIImage you want to use
 *  @param size   the crop CGRect
 *  @param radius the radius value
 *
 *  @return the new UIImage
 */
+ (UIImage *) createRoundedRectImage:(UIImage *)image size:(CGSize)size roundRadius:(CGFloat)radius;

/**
 *  Resize an UIImage with a precise CGSize
 *
 *  @param img       the UIImage you want to use
 *  @param finalSize the new CGSize
 *
 *  @return the new UIImage
 */
+ (UIImage *) returnImage:(UIImage *)img withSize:(CGSize)finalSize;
@end