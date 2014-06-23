//
//  FilterCell.h
//  DBCamera
//
//  Created by Marco De Nadai on 21/06/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBCameraFilterCell : UICollectionViewCell
/**
 *  The name label of the filter
 */
@property (nonatomic, strong) UILabel *label;

/**
 *  The image view contains the example
 */
@property (nonatomic, strong) UIImageView *imageView;
@end