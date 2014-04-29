//
//  DBCameraLibraryViewController.h
//  DBCamera
//
//  Created by iBo on 06/03/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBCameraDelegate.h"

@interface DBCameraLibraryViewController : UIViewController
@property (nonatomic, weak) id <DBCameraContainerDelegate> containerDelegate;
@property (nonatomic, weak) id <DBCameraViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL useCameraSegue;

- (id) initWithDelegate:(id<DBCameraContainerDelegate>)delegate;

@end