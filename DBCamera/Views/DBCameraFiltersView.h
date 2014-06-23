//
//  DBCameraFiltersView.h
//  DBCamera
//
//  Created by Marco De Nadai on 21/06/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBCameraFiltersView : UICollectionView
/**
 *  Return the Filter flow layout used by the collection view
 *
 *  @return The UICollectionViewFlowLayout used by the collection view
 */
+ (UICollectionViewFlowLayout *) filterLayout;
@end