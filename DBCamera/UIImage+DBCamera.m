//
//  UIImage+DBCamera.m
//  DBCamera
//
//  Created by iBo on 01/02/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "UIImage+DBCamera.h"

@implementation UIImage (DBCamera)

- (UIImage *) croppedImage:(CGRect)cropRect
{
    CGImageRef croppedCGImage = CGImageCreateWithImageInRect(self.CGImage ,cropRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:croppedCGImage scale:1.0f orientation:self.imageOrientation];
    CGImageRelease(croppedCGImage);
    
    return croppedImage;
}

- (UIImage *) resizedImage:(CGSize)size imageOrientation:(UIImageOrientation)imageOrientation
{
    CGSize imageSize = self.size;
    CGFloat horizontalRatio = size.width / imageSize.width;
    CGFloat verticalRatio = size.height / imageSize.height;
    CGFloat ratio = MIN(horizontalRatio, verticalRatio);
    CGSize targetSize = (CGSize){ imageSize.width * ratio, imageSize.height * ratio };
    
	UIGraphicsBeginImageContextWithOptions(size, YES, 1.0f);
	CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGContextTranslateCTM(context, 0.0f, -size.height);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    if (imageOrientation == UIImageOrientationRight || imageOrientation == UIImageOrientationRightMirrored) {
        transform = CGAffineTransformTranslate(transform, 0.0f, size.height);
        transform = CGAffineTransformRotate(transform, -M_PI_2);
    } else if (imageOrientation == UIImageOrientationLeft || imageOrientation == UIImageOrientationLeftMirrored) {
        transform = CGAffineTransformTranslate(transform, size.width, 0.0f);
        transform = CGAffineTransformRotate(transform, M_PI_2);
    } else if (imageOrientation == UIImageOrientationDown || imageOrientation == UIImageOrientationDownMirrored) {
        transform = CGAffineTransformTranslate(transform, size.width, size.height);
        transform = CGAffineTransformRotate(transform, M_PI);
    }
    CGContextConcatCTM(context, transform);
    
	CGContextDrawImage(context, (CGRect){ (size.width - targetSize.width) / 2, (size.height - targetSize.height) / 2, targetSize.width, targetSize.height }, self.CGImage );
    
	UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
    return resizedImage;
}

@end