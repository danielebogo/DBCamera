//
//  UIImage+Crop.h
//  DBCamera
//
//  Created by iBo on 11/02/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage(Crop)
+ (UIImage *) screenshotFromView:(UIView *)view;
- (UIImage *) croppedImage:(CGRect)cropRect;
- (UIImage *) rotateUIImage;

+ (UIImage *) createRoundedRectImage:(UIImage *)image size:(CGSize)size roundRadius:(CGFloat)radius;

+ (UIImage *) returnImage:(UIImage *)img withSize:(CGSize)finalSize;
@end