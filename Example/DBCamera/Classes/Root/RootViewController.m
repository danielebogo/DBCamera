//
//  RootViewController.m
//  DBCamera
//
//  Created by iBo on 31/01/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "RootViewController.h"
#import "DBCameraViewController.h"
#import "DBCameraContainer.h"
#import "CustomCamera.h"

#define kCellIdentifier @"CellIdentifier"
#define kCameraTitles @[ @"Open Camera", @"Open Custom Camera", @"Open Camera without Segue", @"Open Camera without Container" ]

@interface DetailViewController : UIViewController {
    UIImageView *_imageView;
}
@property (nonatomic, strong) UIImage *detailImage;
@end

@implementation DetailViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
#endif
    
    [self.navigationItem setTitle:@"Detail"];
    
    _imageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [_imageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [_imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:_imageView];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [_imageView setImage:_detailImage];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface RootViewController () <DBCameraViewControllerDelegate, UITableViewDataSource, UITableViewDelegate> {
    UITableView *_tableView;
}
@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
#endif
    
    [self.navigationItem setTitle:@"Root"];
    
    _tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds] style:UITableViewStyleGrouped];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [self.view addSubview:_tableView];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Camera Actions

- (void) openCamera
{
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[DBCameraContainer alloc] initWithDelegate:self]];
    [nav setNavigationBarHidden:YES];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void) openCustomCamera
{
    CustomCamera *camera = [CustomCamera initWithFrame:[[UIScreen mainScreen] bounds]];
    [camera buildInterface];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[DBCameraViewController alloc] initWithDelegate:self cameraView:camera]];
    [nav setNavigationBarHidden:YES];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void) openCameraWithoutSegue
{
    DBCameraViewController *cameraController = [DBCameraViewController initWithDelegate:self];
    [cameraController setUseCameraSegue:NO];
    DBCameraContainer *container = [[DBCameraContainer alloc] initWithDelegate:self];
    [container setCameraViewController:cameraController];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:container];
    [nav setNavigationBarHidden:YES];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void) openCameraWithoutContainer
{
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[DBCameraViewController initWithDelegate:self]];
    [nav setNavigationBarHidden:YES];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kCameraTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    if ( !cell )
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    
    [[cell textLabel] setText:kCameraTitles[indexPath.row]];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
#endif
    
    switch ( indexPath.row ) {
        case 0:
            [self openCamera];
            break;
            
        case 1:
            [self openCustomCamera];
            break;
        
        case 2:
            [self openCameraWithoutSegue];
            break;
        
        case 3:
            [self openCameraWithoutContainer];
            break;
            
        default:
            break;
    }
}

#pragma mark - DBCameraViewControllerDelegate

- (void) dismissCamera
{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void) captureImageDidFinish:(UIImage *)image withMetadata:(NSDictionary *)metadata
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
#endif
    DetailViewController *detail = [[DetailViewController alloc] init];
    [detail setDetailImage:image];
    [self.navigationController pushViewController:detail animated:NO];
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

@end