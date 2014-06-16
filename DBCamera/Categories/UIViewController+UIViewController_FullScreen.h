//
//  UIViewController+UIViewController_FullScreen.h
//  DBCamera
//
//  Created by Marco De Nadai on 10/06/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 *  Full Screen Mode Category
 */
@interface UIViewController (UIViewController_FullScreen)
/**
 *  Check if the status bar was hidden
 */
@property (nonatomic, assign) BOOL wasStatusBarHidden;

/**
 *  Check if the layout was full screen
 */
@property (nonatomic, assign) BOOL wasFullScreenLayout;

/**
 *  Set the full screen mode on
 */
- (void) setFullScreenMode;

/**
 *  Restore the normal screen mode
 */
- (void) restoreFullScreenMode;
@end