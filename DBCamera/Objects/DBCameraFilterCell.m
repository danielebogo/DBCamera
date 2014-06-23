//
//  FilterCell.m
//  DBCamera
//
//  Created by Marco De Nadai on 21/06/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "DBCameraFilterCell.h"
#import "DBCameraMacros.h"
#import <QuartzCore/QuartzCore.h>

static const NSUInteger kLabelHeight = 18;
static const NSUInteger kCellPadding = 10;
static const NSUInteger kBorderWidth = 1;

@implementation DBCameraFilterCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:RGBColor(0x101010, 1)];
        
        UIView *backgroundCellView = [[UIView alloc] initWithFrame:(CGRect){ 0, kBorderWidth, CGRectGetWidth(self.frame)-kBorderWidth, CGRectGetHeight(self.frame)-kBorderWidth*2 }];
        [backgroundCellView setBackgroundColor:[UIColor blackColor]];
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height-kLabelHeight, self.frame.size.width, kLabelHeight-kCellPadding)];
        [_label setFont:[UIFont systemFontOfSize:9]];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [_label setTextColor:[UIColor whiteColor]];
        [_label setBackgroundColor:[UIColor clearColor]];
        [backgroundCellView addSubview:_label];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kCellPadding, kCellPadding, CGRectGetWidth(self.frame)-kCellPadding*2, CGRectGetHeight(self.frame)-kLabelHeight-kCellPadding*2)];
        [_imageView.layer setCornerRadius:4.0];
        [_imageView.layer setBorderWidth:0.0];
        [_imageView.layer setBorderColor:[RGBColor(0xffffff, .3) CGColor]];
        [_imageView.layer setMasksToBounds:YES];
        
        [backgroundCellView addSubview:_imageView];
        
        [self addSubview:backgroundCellView];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted{
    
}

@end
