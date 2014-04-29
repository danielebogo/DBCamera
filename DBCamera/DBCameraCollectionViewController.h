//
//  DBCameraCollectionViewController.h
//  DBCamera
//
//  Created by iBo on 08/04/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBCameraDelegate.h"

@interface DBCameraCollectionViewController : UIViewController
@property (nonatomic, weak) id <DBCameraCollectionControllerDelegate> collectionControllerDelegate;
@property (nonatomic, strong, readonly) UICollectionView *collectionView;
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, strong) NSArray *items;

- (id)initWithCollectionIdentifier:(NSString *)identifier;
@end