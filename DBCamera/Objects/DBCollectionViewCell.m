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

@end