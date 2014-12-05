//
//  DBCameraVideoSegueViewController.m
//  DBCamera
//
//  Created by dw_iOS on 14-10-14.
//  Copyright (c) 2014年 PSSD - Daniele Bogo. All rights reserved.
//

#import "DBCameraVideoSegueViewController.h"
#import <GPUImage/GPUImage.h>

@interface DBCameraVideoSegueViewController ()

@property (nonatomic, strong) GPUImageView *progressImageView;
@property (nonatomic, strong) AVPlayer *player;

@end

@implementation DBCameraVideoSegueViewController

- (instancetype)initWithVideoALAsset:(ALAsset *)videoAsset {
    self = [super init];
    if (self) {
        NSURL *URL = [[videoAsset defaultRepresentation] url];
        self.imageMovie = [[GPUImageMovie alloc] initWithURL:URL];
        self.imageMovie.runBenchmark = NO;
        self.imageMovie.playAtActualSpeed = NO;
        self.imageMovie.shouldRepeat = YES;
        
        self.player = [[AVPlayer alloc] initWithURL:URL];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    
    self.progressImageView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.progressImageView];
    
    
    GPUImageToneCurveFilter *filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"amaro"];
    [self.imageMovie addTarget:filter];
    [filter addTarget:self.progressImageView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.imageMovie startProcessing];
    [self.player play];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.imageMovie endProcessing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
