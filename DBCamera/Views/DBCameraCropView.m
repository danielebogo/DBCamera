//
//  DBCameraCropView.m
//  CropImage
//
//  Created by Daniele Bogo on 19/04/14.
//  Copyright (c) 2014 Daniele Bogo. All rights reserved.
//

#import "DBCameraCropView.h"

@interface DBCameraCropView () {
    UIImageView *_imageView;
}

@end

@implementation DBCameraCropView
@synthesize cropRect = _cropRect;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setOpaque:NO];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setUserInteractionEnabled:YES];
        [self.layer setOpacity:.7];
        
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [_imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self addSubview:_imageView];
    }
    return self;
}

- (void) setCropRect:(CGRect)cropRect
{
    if( !CGRectEqualToRect(_cropRect, cropRect) ){
        // center the rect
        cropRect = (CGRect){ 0, 0, cropRect.size.width, cropRect.size.height };
        cropRect = CGRectOffset(cropRect, (CGRectGetWidth(self.frame) - CGRectGetWidth(cropRect)) * .5, (CGRectGetHeight(self.frame) - CGRectGetHeight(cropRect)) * .5);

        _cropRect = CGRectOffset(cropRect, self.frame.origin.x, self.frame.origin.y);
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.f);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        [[UIColor blackColor] setFill];
        UIRectFill(self.bounds);
        
        CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] colorWithAlphaComponent:0.5].CGColor);
        CGContextStrokeRect(context, cropRect);
        [[UIColor clearColor] setFill];
        UIRectFill(CGRectInset(cropRect, 1, 1));
        
        [_imageView setImage:UIGraphicsGetImageFromCurrentImageContext()];
        
        UIGraphicsEndImageContext();
    }
}

@end
