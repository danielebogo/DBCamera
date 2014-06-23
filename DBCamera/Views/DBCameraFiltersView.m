//
//  DBCameraFiltersView.m
//  DBCamera
//
//  Created by Marco De Nadai on 21/06/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "DBCameraFiltersView.h"

@implementation DBCameraFiltersView

+ (UICollectionViewFlowLayout *) filterLayout
{
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [layout setMinimumLineSpacing:0.0];
    return layout;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor blackColor]];
    }
    return self;
}

@end