//
//  DBCameraBaseCropViewController.h
//  CropImage
//
//  Created by Daniele Bogo on 19/04/14.
//  Copyright (c) 2014 Daniele Bogo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBCameraDelegate.h"

@interface DBCameraBaseCropViewController : UIViewController
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, copy) UIImage *sourceImage;
@property (nonatomic, copy) UIImage *previewImage;
@property (nonatomic, assign) CGSize cropSize;
@property (nonatomic, assign) CGRect cropRect;
@property (nonatomic, assign) CGFloat outputWidth, minimumScale, maximumScale;
@property (nonatomic, readonly) CGRect cropBoundsInSourceImage;

- (void) enableGestures:(BOOL)enable;
- (void) reset:(BOOL)animated;
- (CGImageRef) newTransformedImage:(CGAffineTransform)transform sourceImage:(CGImageRef)sourceImage sourceSize:(CGSize)sourceSize
                 sourceOrientation:(UIImageOrientation)sourceOrientation outputWidth:(CGFloat)outputWidth
                          cropRect:(CGRect)cropRect imageViewSize:(CGSize)imageViewSize;
@end