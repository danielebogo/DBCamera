//
//  UIViewController+UIViewController_FullScreen.h
//  DBCamera
//
//  Created by Marco De Nadai on 10/06/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (UIViewController_FullScreen)
@property (nonatomic, assign) BOOL wasStatusBarHidden;
@property (nonatomic, assign) BOOL wasFullScreenLayout;

- (void) setFullScreenMode;
- (void) restoreFullScreenMode;
@end
