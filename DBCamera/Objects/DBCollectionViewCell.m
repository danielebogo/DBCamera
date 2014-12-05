//
//  DBCollectionViewCell.m
//  DBCamera
//
//  Created by iBo on 06/03/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "DBCollectionViewCell.h"

@implementation DBCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self.contentView addSubview:self.itemImage];
        
        [self.contentView addSubview:self.itemDuration];
    }
    return self;
}

- (UIImageView *) itemImage
{
    if( !_itemImage ) {
        _itemImage = [[UIImageView alloc] initWithFrame:self.bounds];
        [_itemImage setBackgroundColor:[UIColor clearColor]];
        [_itemImage setContentMode:UIViewContentModeScaleAspectFill];
        [_itemImage setClipsToBounds:YES];
    }
    
    return _itemImage;
}

- (UILabel *) itemDuration
{
    if( !_itemDuration ) {
        CGFloat durationLabelHeight = 20;
        _itemDuration = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - durationLabelHeight, CGRectGetWidth(self.bounds), durationLabelHeight)];
        [_itemDuration setTextColor:[UIColor whiteColor]];
        [_itemDuration setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
        [_itemDuration setTextAlignment:NSTextAlignmentRight];
        [_itemDuration setFont:[UIFont systemFontOfSize:14]];
    }
    
    return _itemDuration;
}

@end