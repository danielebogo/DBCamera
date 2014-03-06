//
//  DBCollectionViewFlowLayout.m
//  DBCamera
//
//  Created by iBo on 06/03/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "DBCollectionViewFlowLayout.h"

@implementation DBCollectionViewFlowLayout

-(id) init
{
    self = [super init];
    if ( self ) {
        [self setItemSize:(CGSize){ 106, 106 }];
        [self setScrollDirection:UICollectionViewScrollDirectionVertical];
        [self setSectionInset:UIEdgeInsetsZero];
        [self setMinimumLineSpacing:1];
        [self setMinimumInteritemSpacing:1];
    }
    return self;
}

- (BOOL) shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds
{
    return YES;
}

@end