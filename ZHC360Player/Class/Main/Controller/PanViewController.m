//
//  PanViewController.m
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/8/26.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import "PanViewController.h"

#define ScleanimateWithDuration 0.3

@implementation PanViewController



- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    //添加按钮在导航条上
    //self.navigationItem.rightBarButtonItem  = [UIBarButtonItem itemWithTitle:@"下载" titleColor:[UIColor yellowColor] target:self action:@selector(rightClick)];
    
    //self.navigationItem.leftBarButtonItem  = [UIBarButtonItem itemWithTitle:@"设置" titleColor:[UIColor brownColor] target:self action:@selector(leftClick)];
    self.navigationItem.title = @"全景视频";
    self.view.backgroundColor = ZHColor(239, 239, 244);
}

- (void)rightClick{
    
//    [self.navigationItem.rightBarButtonItem hideRedPoint];
//    [self.navigationController pushViewController:self.downloadVC animated:YES];
}

- (void)leftClick{
    
    //遮盖拦截操作
    _coverBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _coverBtn.frame = self.navigationController.view.bounds;
    
    [_coverBtn addTarget:self action:@selector(coverClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.view addSubview:_coverBtn];
    
    
    //缩放比例
    CGFloat zoomScale = (ZHAppHeight - ZhScaleTopMargin * 2) / ZHAppHeight;// 上下各距离35
    //x方向移动距离
    CGFloat moveX = ZHAppWidth - ZHAppWidth * ZHZoomScaleRight;
    
    [UIView animateWithDuration:ScleanimateWithDuration  animations:^{
       
        CGAffineTransform transform = CGAffineTransformMakeScale(zoomScale, zoomScale);
        
        self.navigationController.view.transform = CGAffineTransformTranslate(transform,moveX,0);
        
        self.isScale = YES;
    }];
}

- (void)coverClick{
    
    //还原
    [UIView animateWithDuration:ScleanimateWithDuration animations:^{
        //防止继续移动，先重置
        self.navigationController.view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
        [self.coverBtn removeFromSuperview];
        self.coverBtn = nil;
        self.isScale = NO;
        
        if (_coverDidRomove) {
            _coverDidRomove();
        }
    }];
}

@end
