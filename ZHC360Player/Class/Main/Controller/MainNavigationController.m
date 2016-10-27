//
//  MainNavigationController.m
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/8/26.
//  Copyright © 2016年 4DAGE. All rights reserved.
//
//  定义整个工程为UINavigationBar主题

#import "MainNavigationController.h"

@interface MainNavigationController () <UIGestureRecognizerDelegate>

@end

@implementation MainNavigationController

- (void)viewDidLoad{
    
    [super viewDidLoad];
        
    //清空interactivePopGestureRecognizer 的 delegate
    //恢复  替换系统导航条的back按钮  而导致失去的  滑动返回功能
    self.interactivePopGestureRecognizer.delegate = nil;
    
    //禁止手势冲突
    self.interactivePopGestureRecognizer.enabled = NO;
    
    //手动添加手势，触发后调用系统的方法
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self.interactivePopGestureRecognizer.delegate action:@selector(handleNavigationTransition:)];
    
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
}



+ (void)initialize{
    
    UINavigationBar *bar = [UINavigationBar appearanceWhenContainedIn:self, nil];
    
    [bar setBackgroundImage:[UIImage imageNamed:@"recomend_btn_gone"] forBarMetrics:UIBarMetricsDefault];
    
    //去掉导航条的半透明(iOS7之后的方法，默认半透明)
    bar.translucent = NO;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[NSFontAttributeName] = [UIFont systemFontOfSize:20];
    dict[NSForegroundColorAttributeName] = [UIColor whiteColor];
    
    [bar setTitleTextAttributes:dict];
}

#pragma mark - 添加的手势代理方法
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    
    //判断当前控制器是否根控制器
    return (self.topViewController != [self.viewControllers firstObject]);
}
@end
