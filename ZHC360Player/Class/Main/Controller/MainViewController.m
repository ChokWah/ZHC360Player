//
//  ViewController.m
//  4DAGEVR_demo
//
//  Created by 4DAGE_HUA on 16/5/5.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import "MainViewController.h"
#import "PanViewController.h"
#import "MainNavigationController.h"
#import "HomeViewController.h"
#import "ZHLeftMenuView.h"

@interface MainViewController ()<UIGestureRecognizerDelegate,ZHLeftMenuViewDelegate>

// 记录当前显示的控制器，用于添加手势
@property (nonatomic, weak) PanViewController *showViewController;

@property (nonatomic, weak) ZHLeftMenuView *leftView;

@end

@implementation MainViewController

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    //子控制器
    NSArray *subClass = @[@"HomeViewController"];
    
    for (NSString *className in subClass) {
        
        UIViewController *vc = (UIViewController *)[[NSClassFromString(className) alloc] init];

        MainNavigationController *nc = [[MainNavigationController alloc] initWithRootViewController:vc];
        
        nc.view.layer.shadowColor    = [UIColor blackColor].CGColor;
        nc.view.layer.shadowOffset   = CGSizeMake(-3.5, 0);
        nc.view.layer.shadowOpacity  = 0.2;
        [self addChildViewController:nc];
    }
    
    //创建左边view，添加约束
    ZHLeftMenuView *leftV = [[ZHLeftMenuView alloc] init];
    leftV.backgroundColor = [UIColor yellowColor];
    leftV.delegate = self;
    [self.view insertSubview:leftV atIndex:0];
    
    //autoLayout
    [leftV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.top.equalTo(self.view.mas_top).offset(40);
        make.bottom.equalTo(self.view.mas_bottom).offset(-20);
        make.width.equalTo(self.view.mas_width).multipliedBy(0.8);

    }];
    
    self.leftView = leftV;
    
    //添加手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
    
}

- (void)pan:(UIPanGestureRecognizer *)pan{
    
    CGFloat moveX = [pan translationInView:self.view].x;
    
    //缩放的最终比例值
    CGFloat zoomScale = (ZHAppHeight - ZhScaleTopMargin * 2) / ZHAppHeight;
    
    //X最终偏移距离
    CGFloat maxMoveX = ZHAppWidth - ZHAppWidth * ZHZoomScaleRight;
    
    //没有缩放时，允许缩放
    if (self.showViewController.isScale == NO) {
        
        if (moveX <= maxMoveX + 5 && moveX >= 0) {
            
            //获取X偏移XY缩放的比例
            CGFloat scaleXY = 1 - moveX / maxMoveX * ZHZoomScaleRight;
            
            CGAffineTransform transform = CGAffineTransformMakeScale(scaleXY, scaleXY);
            
            self.showViewController.navigationController.view.transform = CGAffineTransformTranslate(transform, moveX / scaleXY, 0);
        }
        
        //当手势停止的时候,判断X轴的移动距离，停靠
        if (pan.state == UIGestureRecognizerStateEnded) {
            //计算剩余停靠时间
            if (moveX >= maxMoveX / 2) {
                CGFloat duration = 0.5 * (maxMoveX - moveX)/maxMoveX > 0 ? 0.5 * (maxMoveX - moveX)/maxMoveX : -(0.5 * (maxMoveX - moveX)/maxMoveX);
                if (duration <= 0.1) duration = 0.1;
                //直接停靠到停止的位置
                [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                    CGAffineTransform tt = CGAffineTransformMakeScale(zoomScale, zoomScale);
                    self.showViewController.navigationController.view.transform = CGAffineTransformTranslate(tt, maxMoveX , 0);
                    
                } completion:^(BOOL finished) {
                    //将状态改为已经缩放
                    self.showViewController.isScale = YES;
                    //手动点击按钮添加遮盖
                    [self.showViewController leftClick];
                }];
                
            } else  {//X轴移动不够一半 回到原位,不是缩放状态
                
                [UIView animateWithDuration:0.2 animations:^{
                    self.showViewController.navigationController.view.transform = CGAffineTransformIdentity;
                } completion:^(BOOL finished) {
                    self.showViewController.isScale = NO;
                }];
            }
        }
    }
    else if (self.showViewController.isScale == YES) {
        //已经缩放的情况下
        
        //计算比例
        CGFloat scaleXY = zoomScale - moveX / maxMoveX * ZHZoomScaleRight;
        
        if (moveX <= 5) {
            
            CGAffineTransform transform = CGAffineTransformMakeScale(scaleXY, scaleXY);
            self.showViewController.navigationController.view.transform = CGAffineTransformTranslate(transform, (moveX + maxMoveX), 0);
        }
        //当手势停止的时候,判断X轴的移动距离，停靠
        if (pan.state == UIGestureRecognizerStateEnded) {
            //计算剩余停靠时间
            if (-moveX >= maxMoveX / 2) {
                CGFloat duration = 0.5 * (maxMoveX + moveX)/maxMoveX > 0 ? 0.5 * (maxMoveX + moveX)/maxMoveX : -(0.5 * (maxMoveX + moveX)/maxMoveX);
                
                if (duration <= 0.1) {
                    duration = 0.1;
                }
                //直接停靠到停止的位置
                [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                    
                    self.showViewController.navigationController.view.transform = CGAffineTransformIdentity;
                } completion:^(BOOL finished) {
                    self.showViewController.isScale = NO;
                    [self.showViewController coverClick];
                }];
                
            } else {//X轴移动不够一半 回到原位,不是缩放状态
                
                [UIView animateWithDuration:0.2 animations:^{
                    
                    CGAffineTransform tt = CGAffineTransformMakeScale(zoomScale, zoomScale);
                    self.showViewController.navigationController.view.transform = CGAffineTransformTranslate(tt, maxMoveX, 0);
                } completion:^(BOOL finished) {
                    self.showViewController.isScale = YES;
                }];
            }
        }
    }
    
}

- (void)leftMenuViewButtonClcik{
    
    MainNavigationController *newVC = self.childViewControllers[0];
    [self.view addSubview:newVC.view];
    
    self.showViewController = newVC.childViewControllers[0];
    [self.showViewController coverClick];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
