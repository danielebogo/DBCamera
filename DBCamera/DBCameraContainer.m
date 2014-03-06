//
//  DBCameraContainer.m
//  DBCamera
//
//  Created by iBo on 06/03/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "DBCameraContainer.h"
#import "DBCameraViewController.h"
#import "DBCameraMacros.h"

@interface DBCameraContainer () <DBCameraContainerDelegate>
@property (nonatomic, strong) DBCameraViewController *defaultCameraViewController;
@end

@implementation DBCameraContainer

- (id) initWithDelegate:(id<DBCameraViewControllerDelegate>)delegate
{
    self = [super init];
    
    if ( self ) {
        _delegate = delegate;
    }
    
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:RGBColor(0x000000, 1)];
    
    if ( !self.defaultCameraViewController.containerDelegate )
        [self.defaultCameraViewController setContainerDelegate:self];
    
    [self addChildViewController:self.defaultCameraViewController];
    [self.view addSubview:self.defaultCameraViewController.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

- (DBCameraViewController *) defaultCameraViewController
{
    if ( !_defaultCameraViewController )
        _defaultCameraViewController = [DBCameraViewController initWithDelegate:_delegate];
    
    return ( self.cameraViewController ) ? self.cameraViewController : _defaultCameraViewController;
}

#pragma mark - DBCameraContainerDelegate

- (void) backFromController:(id)fromController
{
    [self switchFromController:fromController
                  toController:self.defaultCameraViewController];
}

- (void) switchFromController:(id)fromController toController:(id)controller
{
    [[(UIViewController *)controller view] setAlpha:1];
    [[(UIViewController *)controller view] setTransform:CGAffineTransformMakeScale(1, 1)];
    [self addChildViewController:controller];
    
    __block id blockViewController = fromController;
    
    [self transitionFromViewController:blockViewController
                      toViewController:controller
                              duration:.2
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^(void){ }
                            completion:^(BOOL finished) {
                                [blockViewController removeFromParentViewController];
                                blockViewController = nil;
                            }];
}

@end