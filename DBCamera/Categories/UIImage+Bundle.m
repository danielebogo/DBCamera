//
//  UIImage+Bundle.m
//  DBCamera
//
//  Created by Dongyuan Liu on 2015-07-15.
//  Copyright (c) 2015 PSSD - Daniele Bogo. All rights reserved.
//

#import "UIImage+Bundle.h"
#import "DBCameraViewController.h"

@implementation UIImage (Bundle)

+ (UIImage *)imageInBundleNamed:(NSString *)name {

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    
    if ([UIImage respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
        // return image in the bundle in current framework
        return [UIImage imageNamed:name inBundle:[NSBundle bundleForClass:[DBCameraViewController class]] compatibleWithTraitCollection:nil];
    }
    else
        
#endif
    
    {
        return [UIImage imageNamed:name];
    }
}

@end
