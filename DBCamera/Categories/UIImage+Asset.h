//
//  UIImage+Asset.h
//  DBCamera
//
//  Created by iBo on 23/06/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ALAsset;
@interface UIImage (Asset)
/**
 *  Return an UIImage from the ALAsset
 *
 *  @param asset The asset in use
 *  @param size  The maximum size for the UIImage
 *
 *  @return An UIImage
 */
+ (UIImage *) imageForAsset:(ALAsset *)asset maxPixelSize:(NSUInteger)size;
@end