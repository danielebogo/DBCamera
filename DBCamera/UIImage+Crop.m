//
//  UIImage+Crop.m
//  DBCamera
//
//  Created by iBo on 11/02/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "UIImage+Crop.h"

@implementation UIImage(Crop)

+ (UIImage *) screenshotFromView:(UIView *)view
{
    CGFloat width = view.frame.size.width * 2.0f;
    CGFloat height = view.frame.size.height * 2.0f;
    UIGraphicsBeginImageContextWithOptions((CGSize){ width, height }, YES, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *fullScreenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return fullScreenshot;
}

- (UIImage *) croppedImage:(CGRect)cropRect
{
    CGImageRef croppedCGImage = CGImageCreateWithImageInRect(self.CGImage ,cropRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:croppedCGImage scale:1 orientation:self.imageOrientation];
    CGImageRelease(croppedCGImage);
    
    return croppedImage;
}

@end
