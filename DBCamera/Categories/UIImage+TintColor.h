//
//  UIImage+TintColor.h
//  DBCamera
//
//  Created by iBo on 22/05/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  UIImage TintColor category
 */
@interface UIImage (TintColor)
/**
 *  Tint the image using this method/
 *
 *  @param tintColor the color you selected
 *
 *  @return the image tinted with the color you selected
 */
- (UIImage *) tintImageWithColor:(UIColor *)tintColor;
@end