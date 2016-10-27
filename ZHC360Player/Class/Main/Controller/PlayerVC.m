//
//  PlayerVC.m
//  4DAGEVR_demo
//
//  Created by 4DAGE_HUA on 16/5/25.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import "PlayerVC.h"
#import "GVRVideoView.h"
#import <GLKit/GLKit.h>
#import "AppDelegate.h"


@interface PlayerVC ()<GVRVideoViewDelegate>{BOOL _isPaused;}

@property (nonatomic, strong)  GVRVideoView *videoView;
@property (nonatomic, strong)  UIButton     *backBtn;
@property (nonatomic, strong)  UIImageView  *playLogo;
@property (nonatomic, copy)    NSURL     *videourl;

@end

@implementation PlayerVC
@synthesize videourl;


- (instancetype)initWithVideoName:(NSURL *)nameStr{
    
    if (self = [super init]) {
        
        videourl = nameStr;
    }
    return self;
}


- (GVRVideoView *)videoView{
    
    if (_videoView == nil) {
        
        _videoView = [[GVRVideoView alloc]initWithFrame:self.view.frame];
    }
    return _videoView;
    
}


- (void)viewWillAppear:(BOOL)animated{
    
    self.navigationController.toolbarHidden = YES;
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationController.toolbarHidden = YES;
    
    [self setupVideoView];
    
    [self setupPlayLogo];
    
    [self setupBackButton];
    
    [self.videoView loadFromUrl:videourl];
    
    
}


#pragma mark - 设置VideoView和返回button的约束
- (void)setupVideoView{
    
    [self.view addSubview:self.videoView];
    UIEdgeInsets padding = UIEdgeInsetsMake(0, 0, 0, 0);
    
    [self.videoView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.view.mas_top).with.offset(padding.top); //with is an optional semantic filler
        make.left.equalTo(self.view.mas_left).with.offset(padding.left);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-padding.bottom);
        make.right.equalTo(self.view.mas_right).with.offset(-padding.right);
    }];
    
    self.videoView.delegate = self;
    self.videoView.enableFullscreenButton = NO;
    self.videoView.enableCardboardButton  = YES;
    _isPaused = NO;
    
}

- (void)setupBackButton{
    
    _backBtn = [[UIButton alloc]init];
    [_backBtn setBackgroundImage:[UIImage imageNamed:@"key_return.png"] forState:UIControlStateNormal];
    [self.videoView addSubview:_backBtn];
    [self.videoView bringSubviewToFront:_backBtn];
    [_backBtn addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchDown];

    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(self.view).offset(-7);
        make.leading.equalTo(self.view).offset(10);
        make.size.mas_equalTo(CGSizeMake(35, 35));
    }];
}

- (void)setupPlayLogo{
    
    _playLogo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"control_play.png"]];
    [self.videoView addSubview:_playLogo];
    [_videoView bringSubviewToFront:_playLogo];
    _playLogo.hidden = YES;
    [_playLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.videoView);
    }];
}

- (void)backBtnAction{
    
    __weak PlayerVC *this = self;
    
    //[this.navigationController popViewControllerAnimated:YES];
    [this dismissViewControllerAnimated:YES completion:^{
        
        self.videoView.delegate = nil;
        [_backBtn removeFromSuperview];
        [self.videoView removeFromSuperview];
        _videoView = nil;
        _backBtn = nil;
    }];
}


#pragma mark - GCSVideoViewDelegate
- (void)widgetViewDidTap:(GVRWidgetView *)widgetView {
    
    if (_isPaused) {
        [self.videoView resume];
        NSLog(@"开始播放");
        _playLogo.hidden = YES;
    } else {
        [self.videoView pause];
        NSLog(@"暂停播放");
        _playLogo.hidden = NO;
    }
    _isPaused = !_isPaused;
}


- (void)widgetView:(GVRWidgetView *)widgetView didLoadContent:(id)content {
    NSLog(@"Finished loading video, %@",content);
}

- (void)widgetView:(GVRWidgetView *)widgetView
didFailToLoadContent:(id)content
  withErrorMessage:(NSString *)errorMessage {
    
    NSLog(@"Failed to load video: %@", errorMessage);
    [MBProgressHUD showError:errorMessage];
    [self backBtnAction];
}

- (void)videoView:(GVRVideoView*)videoView didUpdatePosition:(NSTimeInterval)position {
    // Loop the video when it reaches the end.
    
    NSLog(@"进度：%f ，总长度: %f",position,videoView.duration);
    if (position == videoView.duration) {
        [self.videoView seekTo:0];
        [self.videoView resume];
    }
}

- (void)widgetView:(GVRWidgetView *)widgetView
didChangeDisplayMode:(GVRWidgetDisplayMode)displayMode{
    
    [widgetView.subviews[0] setNeedsLayout];
    NSLog(@" 播放模式改变: %ld",(long)displayMode);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
