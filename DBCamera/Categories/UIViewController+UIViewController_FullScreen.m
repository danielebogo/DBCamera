//
//  UIViewController+UIViewController_FullScreen.m
//  DBCamera
//
//  Created by Marco De Nadai on 10/06/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "UIViewController+UIViewController_FullScreen.h"
#import <objc/runtime.h>

@implementation UIViewController (UIViewController_FullScreen)

- (void) setFullScreenMode
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    self.wasStatusBarHidden = [UIApplication sharedApplication].statusBarHidden;
    self.wasFullScreenLayout = self.wantsFullScreenLayout;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [self setWantsFullScreenLayout:YES];
#elif __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
#endif
}

- (void) restoreFullScreenMode
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    [[UIApplication sharedApplication] setStatusBarHidden:self.wasStatusBarHidden withAnimation:UIStatusBarAnimationSlide];
    [self setWantsFullScreenLayout:self.wasFullScreenLayout];
#endif
}

- (BOOL)wasStatusBarHidden
{
    NSNumber *number = objc_getAssociatedObject(self, @selector(wasStatusBarHidden));
    return [number boolValue];
}

- (void)setWasStatusBarHidden:(BOOL)property
{
    NSNumber *number = [NSNumber numberWithBool: property];
    objc_setAssociatedObject(self, @selector(wasStatusBarHidden), number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)wasFullScreenLayout
{
    NSNumber *number = objc_getAssociatedObject(self, @selector(wasFullScreenLayout));
    return [number boolValue];
}

- (void)setWasFullScreenLayout:(BOOL)property
{
    NSNumber *number = [NSNumber numberWithBool: property];
    objc_setAssociatedObject(self, @selector(wasFullScreenLayout), number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end