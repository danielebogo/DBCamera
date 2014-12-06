//
//  UIImage+Asset.m
//  DBCamera
//
//  Created by iBo on 23/06/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "UIImage+Asset.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>

@implementation UIImage (Asset)

static size_t getAssetBytesCallback(void *info, void *buffer, off_t position, size_t count) {
    ALAssetRepresentation *rep = (__bridge id)info;
    NSError *error = nil;
    size_t countRead = [rep getBytes:(uint8_t *)buffer fromOffset:position length:count error:&error];
    if (countRead == 0 && error) {
        // We have no way of passing this info back to the caller, so we log it, at least.
        NSLog(@"thumbnailForAsset:maxPixelSize: got an error reading an asset: %@", error);
    }
    return countRead;
}

static void releaseAssetCallback(void *info) {
    // The info here is an ALAssetRepresentation which we CFRetain in thumbnailForAsset:maxPixelSize:.
    // This release balances that retain.
    CFRelease(info);
}

+ (UIImage *) imageForAsset:(ALAsset *)asset maxPixelSize:(NSUInteger)size
{
    NSParameterAssert(asset != nil);
    NSParameterAssert(size > 0);
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    CGDataProviderDirectCallbacks callbacks = {
        .version = 0,
        .getBytePointer = NULL,
        .releaseBytePointer = NULL,
        .getBytesAtPosition = getAssetBytesCallback,
        .releaseInfo = releaseAssetCallback,
    };
    CGDataProviderRef provider = CGDataProviderCreateDirect((void *)CFBridgingRetain(rep), [rep size], &callbacks);
    CGImageSourceRef source = CGImageSourceCreateWithDataProvider(provider, NULL);
    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef) @{
                                                                                                      (NSString *)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                                                                                                      (NSString *)kCGImageSourceThumbnailMaxPixelSize : @(size),
                                                                                                      (NSString *)kCGImageSourceCreateThumbnailWithTransform : @YES,
                                                                                                      });
    CFRelease(source);
    CFRelease(provider);
    
    if (!imageRef) {
        return nil;
    }
    
//    NSString *adjustmentXMP = [rep.metadata objectForKey:@"AdjustmentXMP"];
//    NSData *adjustmentXMPData = [adjustmentXMP dataUsingEncoding:NSUTF8StringEncoding];
//    NSError *__autoreleasing error = nil;
//    CGRect extend = CGRectZero;
//    extend.size = (CGSize){ CGImageGetWidth(imageRef), CGImageGetHeight(imageRef) };
//    NSArray *filters = [CIFilter filterArrayFromSerializedXMP:adjustmentXMPData inputImageExtent:extend error:&error];
//    if (filters)
//    {
//        CIImage *image = [CIImage imageWithCGImage:imageRef];
//        CIContext *context = [CIContext contextWithOptions:nil];
//        for (CIFilter *filter in filters)
//        {
//            [filter setValue:image forKey:kCIInputImageKey];
//            image = [filter outputImage];
//        }
//        
//        imageRef = [context createCGImage:image fromRect:image.extent];
//    }
    
    
    UIImage *toReturn = [UIImage imageWithCGImage:imageRef];
    CFRelease(imageRef);
    return toReturn;
}

@end