//
//  RootViewController.m
//  DBCamera
//
//  Created by iBo on 31/01/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "RootViewController.h"
#import "DBCameraViewController.h"
#import "DBCameraContainerViewController.h"
#import "DBCameraLibraryViewController.h"
#import "CustomCamera.h"
#import "DBCameraGridView.h"
#import <MediaPlayer/MediaPlayer.h>

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

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    _detailImage = nil;
    [_imageView setImage:nil];
}

@end

@interface VideoDetailViewController : UIViewController {
    
}

@property (nonatomic, strong) NSURL *videoURL;

@property (nonatomic, strong) MPMoviePlayerController *moviePlayerController;

@end

@implementation VideoDetailViewController

- (MPMoviePlayerController *)moviePlayerController {
    if (!_moviePlayerController) {
        _moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:self.videoURL];
        _moviePlayerController.repeatMode = MPMovieRepeatModeOne;
        _moviePlayerController.scalingMode = MPMovieScalingModeAspectFill;
        _moviePlayerController.view.frame = self.view.frame;
    }
    return _moviePlayerController;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
#endif
    
    [self.navigationItem setTitle:@"VideoDetail"];
    
    [self.view addSubview:self.moviePlayerController.view];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.moviePlayerController play];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_moviePlayerController stop];
    _moviePlayerController = nil;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#define kCellIdentifier @"CellIdentifier"
#define kCameraTitles @[ @"Open Camera", @"Open Custom Camera", @"Open Camera without Segue", @"Open Camera without Container", @"Camera with force quad crop", @"Open Library Picker" ]

typedef void (^TableRowBlock)();

@interface RootViewController () <DBCameraViewControllerDelegate, UITableViewDataSource, UITableViewDelegate> {
    UITableView *_tableView;
    NSDictionary *_actionMapping;
}
@end

@implementation RootViewController

- (id) init
{
    self = [super init];
    
    if ( self ) {
        _actionMapping = @{ @0:^{ [self openCamera]; }, @1:^{ [self openCustomCamera]; },
                            @2:^{ [self openCameraWithoutSegue]; }, @3:^{ [self openCameraWithoutContainer]; },
                            @4:^{ [self openCameraWithForceQuad]; }, @5:^{ [self openLibrary]; } };
    }
    
    return self;
}

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
/*
//If you want to customize the camera view, use initWithDelegate:cameraSettingsBlock:
 
    DBCameraContainerViewController *cameraContainer = [[DBCameraContainerViewController alloc] initWithDelegate:self cameraSettingsBlock:^(DBCameraView *cameraView, DBCameraContainerViewController *container) {
        [cameraView.photoLibraryButton setHidden:YES]; //Hide Library button
     
        //Override the camera grid
        DBCameraGridView *cameraGridView = [[DBCameraGridView alloc] initWithFrame:cameraView.previewLayer.frame];
        [cameraGridView setNumberOfColumns:4];
        [cameraGridView setNumberOfRows:4];
        [cameraGridView setAlpha:0];
        [container.cameraViewController setCameraGridView:cameraGridView];
        [container.cameraViewController setUseCameraSegue:NO];
    }];

//Set the Tint Color and the Selected Color
    [cameraContainer setTintColor:[UIColor redColor]];
    [cameraContainer setSelectedTintColor:[UIColor yellowColor]];
*/

    DBCameraContainerViewController *cameraContainer = [[DBCameraContainerViewController alloc] initWithDelegate:self];
    [cameraContainer setFullScreenMode];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cameraContainer];
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
//    [cameraController setLibraryMaxImageSize:1280]; //You can set a value for the maximum output resolution for the image selected from the Library
    
    DBCameraContainerViewController *container = [[DBCameraContainerViewController alloc] initWithDelegate:self];
    [container setCameraViewController:cameraController];
    [container setFullScreenMode];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:container];
    [nav setNavigationBarHidden:YES];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void) openCameraWithForceQuad
{
    DBCameraViewController *cameraController = [DBCameraViewController initWithDelegate:self];
    [cameraController setForceQuadCrop:YES];
    
    DBCameraContainerViewController *container = [[DBCameraContainerViewController alloc] initWithDelegate:self];
    [container setCameraViewController:cameraController];
    [container setFullScreenMode];

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

- (void) openLibrary
{
    DBCameraLibraryViewController *vc = [[DBCameraLibraryViewController alloc] init];
    [vc setDelegate:self]; //DBCameraLibraryViewController must have a DBCameraViewControllerDelegate object
//    [vc setForceQuadCrop:YES]; //Optional
//    [vc setUseCameraSegue:YES]; //Optional
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
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
    
    TableRowBlock block = _actionMapping[@(indexPath.row)];
    block();
}

#pragma mark - DBCameraViewControllerDelegate

- (void) dismissCamera:(id)cameraViewController{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    [cameraViewController restoreFullScreenMode];
}

- (void) camera:(id)cameraViewController didFinishWithImage:(UIImage *)image withMetadata:(NSDictionary *)metadata
{
    DetailViewController *detail = [[DetailViewController alloc] init];
    [detail setDetailImage:image];
    [self.navigationController pushViewController:detail animated:NO];
    [cameraViewController restoreFullScreenMode];
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void) camera:(id)cameraViewController didFinishWithVideoALAsset:(ALAsset *)videoAsset {
    VideoDetailViewController *detail = [[VideoDetailViewController alloc] init];
    detail.videoURL = [[videoAsset defaultRepresentation] url];
    [self.navigationController pushViewController:detail animated:NO];
    [cameraViewController restoreFullScreenMode];
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

@end