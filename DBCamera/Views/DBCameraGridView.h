//
//  XHGridView.h
//  iyilunba
//
//  Created by 曾 宪华 on 13-11-7.
//  Copyright (c) 2013年 曾 宪华 开发团队(http://iyilunba.com ). All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  The grid view of the camera
 */
@interface DBCameraGridView : UIView
/**
 *  The line width of a line. Default value is 1.0.
 */
@property (nonatomic, assign) CGFloat lineWidth;

/**
 *  The number of the grid's columns
 */
@property (nonatomic, assign) NSUInteger numberOfColumns;

/**
 *  The number of the grid's rows
 */
@property (nonatomic, assign) NSUInteger numberOfRows;
@end