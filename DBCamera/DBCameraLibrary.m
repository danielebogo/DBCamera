//
//  DBCameraLibrary.m
//  DBCamera
//
//  Created by iBo on 06/03/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "DBCameraLibrary.h"
#import "DBLibraryManager.h"
#import "DBCollectionViewCell.h"
#import "DBCollectionViewFlowLayout.h"
#import "DBCameraSegueViewController.h"
#import "UIImage+Crop.h"
#import "DBCameraMacros.h"

#define kItemIdentifier @"ItemIdentifier"

@interface DBCameraLibrary () <UICollectionViewDataSource, UICollectionViewDelegate> {
    NSMutableArray *_items;
    UICollectionView *_collectionView;
}
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIView *topContainerBar, *loading;;
@end

@implementation DBCameraLibrary

- (id) initWithDelegate:(id<DBCameraContainerDelegate>)delegate
{
    self = [super init];
    if (self) {
        _containerDelegate = delegate;
        _items = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:self.topContainerBar];
    [self.view addSubview:self.closeButton];
    
    CGRect frame = (CGRect){ 0, CGRectGetMaxY(self.topContainerBar.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.topContainerBar.frame) };
    
    _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:[[DBCollectionViewFlowLayout alloc] init]];
    [_collectionView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [_collectionView setDelegate:self];
    [_collectionView setDataSource:self];
    [_collectionView setBackgroundColor:self.view.backgroundColor];
    [_collectionView registerClass:[DBCollectionViewCell class] forCellWithReuseIdentifier:kItemIdentifier];
    [self.view addSubview:_collectionView];
    
    [self.view addSubview:self.loading];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    __weak NSMutableArray *blockItems = _items;
    __weak UICollectionView *blockCollection = _collectionView;
    __weak typeof(self) blockSelf = self;
    [[DBLibraryManager sharedInstance] loadAssetsWithBlock:^(BOOL success, NSArray *items) {
        if ( success ) {
            [blockItems addObjectsFromArray:items];
            [blockCollection reloadData];
            [blockSelf.loading removeFromSuperview];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) close
{
    [UIView animateWithDuration:.3 animations:^{
        [self.view setAlpha:0];
        [self.view setTransform:CGAffineTransformMakeScale(.8, .8)];
    } completion:^(BOOL finished) {
        [self.containerDelegate backFromController:self];
    }];
}

- (UIView *) loading
{
    if( !_loading ) {
        _loading = [[UIView alloc] initWithFrame:(CGRect){ 0, 0, 100, 100 }];
        [_loading.layer setCornerRadius:10];
        [_loading setBackgroundColor:RGBColor(0x000000, .7)];
        [_loading setCenter:self.view.center];
        [_loading setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin];
        
        UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activity setCenter:(CGPoint){ CGRectGetMidX(_loading.bounds), CGRectGetMidY(_loading.bounds) }];
        [_loading addSubview:activity];
        [activity startAnimating];
    }
    
    return _loading;
}

- (UIView *) topContainerBar
{
    if ( !_topContainerBar ) {
        _topContainerBar = [[UIView alloc] initWithFrame:(CGRect){ 0, 0, CGRectGetWidth(self.view.bounds), 65 }];
        _topContainerBar.backgroundColor = [UIColor blackColor];
    }
    return _topContainerBar;
}

- (UIButton *) closeButton
{
    if ( !_closeButton ) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setBackgroundColor:[UIColor clearColor]];
        [_closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [_closeButton setFrame:(CGRect){ 0,  0, 30, 30 }];
        [_closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton setCenter:self.topContainerBar.center];
    }
    
    return _closeButton;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return _items.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DBCollectionViewCell *item = [collectionView dequeueReusableCellWithReuseIdentifier:kItemIdentifier forIndexPath:indexPath];
    [item.itemImage setImage:nil];
    
    if ( _items.count > 0) {
        __weak DBCollectionViewCell *blockItem = item;
        [[[DBLibraryManager sharedInstance] defaultAssetsLibrary] assetForURL:(NSURL *)_items[indexPath.item]  resultBlock:^(ALAsset *asset) {
            UIImage *image = [UIImage imageWithCGImage:[asset thumbnail]];
            [blockItem.itemImage setImage:image];
        } failureBlock:nil];
    }
    
    return item;
}

#pragma mark - UICollectionViewDelegate

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view addSubview:self.loading];
        
        __weak typeof(self) blockSelf = self;
        [[[DBLibraryManager sharedInstance] defaultAssetsLibrary] assetForURL:(NSURL *)_items[indexPath.item]  resultBlock:^(ALAsset *asset) {
            ALAssetRepresentation *defaultRep = [asset defaultRepresentation];
            UIImage *image = [UIImage imageWithCGImage:[defaultRep fullResolutionImage]
                                                 scale:[defaultRep scale]
                                           orientation:[[asset valueForProperty:ALAssetPropertyOrientation] integerValue]];
            
            if ( !blockSelf.useCameraSegue ) {
                if ( [blockSelf.delegate respondsToSelector:@selector(captureImageDidFinish:withMetadata:)] )
                    [blockSelf.delegate captureImageDidFinish:[image rotateUIImage]
                                                 withMetadata:[defaultRep metadata]];
            } else {
                DBCameraSegueViewController *segue = [[DBCameraSegueViewController alloc] init];
                [segue setCapturedImage:[image rotateUIImage]];
                [segue setCapturedImageMetadata:[defaultRep metadata]];
                [segue setDelegate:blockSelf.delegate];
                [blockSelf.navigationController pushViewController:segue animated:YES];
            }
            
            [blockSelf.loading removeFromSuperview];
            
        } failureBlock:nil];
    });
}

@end