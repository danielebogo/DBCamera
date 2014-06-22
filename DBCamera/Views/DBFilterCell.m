//
//  FilterCell.m
//  DBCamera
//
//  Created by Marco De Nadai on 21/06/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "DBFilterCell.h"
#import <QuartzCore/QuartzCore.h>

static const int kLabelHeight = 18;
static const int kCellPadding = 10;
static const int kBorderWidth = 1;

@implementation DBFilterCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIColor *DBGreyColor = [UIColor colorWithRed:16/255.f green:16/255.f blue:16/255.f alpha:1.0f];
        self.backgroundColor = DBGreyColor;
        
        UIView *backgroundCellView = [[UIView alloc] initWithFrame:CGRectMake(0, kBorderWidth, self.frame.size.width-kBorderWidth, self.frame.size.height-kBorderWidth*2)];
        backgroundCellView.backgroundColor = [UIColor blackColor];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height-kLabelHeight, self.frame.size.width, kLabelHeight-kCellPadding)];
        self.label.font = [UIFont systemFontOfSize:9];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.textColor = [UIColor whiteColor];
        self.label.backgroundColor = [UIColor clearColor];
        [backgroundCellView addSubview:self.label];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kCellPadding, kCellPadding, self.frame.size.width-kCellPadding*2, self.frame.size.height-kLabelHeight-kCellPadding*2)];
        self.imageView.layer.cornerRadius = 4.f;
        self.imageView.layer.borderWidth = 0.0f;
        self.imageView.layer.borderColor = [[UIColor colorWithRed:255/255.f green:255/255.f blue:255/255.f alpha:0.3f] CGColor];
        self.imageView.layer.masksToBounds = YES;
        
        [backgroundCellView addSubview:self.imageView];
        
        [self addSubview:backgroundCellView];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted{
    
}

@end
