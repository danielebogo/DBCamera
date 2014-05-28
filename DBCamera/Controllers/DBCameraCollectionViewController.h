//
//  DBCameraCollectionViewController.h
//  DBCamera
//
//  Created by iBo on 08/04/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBCameraDelegate.h"

/**
 *  DBCameraCollectionViewController
 */
@interface DBCameraCollectionViewController : UIViewController
/**
 *  An id object compliant to DBCameraCollectionControllerDelegate
 */
@property (nonatomic, weak) id <DBCameraCollectionControllerDelegate> collectionControllerDelegate;

/**
 *  The collection view of the controller
 */
@property (nonatomic, strong, readonly) UICollectionView *collectionView;

/**
 *  The current index of the controller
 */
@property (nonatomic, assign) NSUInteger currentIndex;

/**
 *  The items of the collection view
 */
@property (nonatomic, strong) NSArray *items;

/**
 *  Initialize the view controller with an identifier
 *
 *  @param identifier The identifier used to initialize the view controller
 *
 *  @return A DBCameraCollectionViewController
 */
- (id)initWithCollectionIdentifier:(NSString *)identifier;
@end