//
//  ZH.m
//  ZH_4DAGE_AR
//
//  Created by 4DAGE_HUA on 16/4/14.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIBarButtonItem_ZHExtension.h"

@implementation UIBarButtonItem (ZHExtension)

+ (instancetype)itemWithImage:(NSString *)image highImage:(NSString *)highImage target:(id)target action:(SEL)action{
    
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:highImage] forState:UIControlStateHighlighted];
        [button sizeToFit];
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        
        return [[UIBarButtonItem alloc] initWithCustomView:button];
    }
}

+ (UIBarButtonItem *)itemWithBigImage:(NSString *)image target:(id)target action:(SEL)action{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *Bigimage = [UIImage imageNamed:image];
    
    button.frame = CGRectMake(0, 0, 35, 35);
    [button setBackgroundImage:Bigimage forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc]initWithCustomView:button];
}


+ (UIBarButtonItem *)itemWithNormalImage:(NSString *)image target:(id)target action:(SEL)action{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *Bigimage = [UIImage imageNamed:image];
    
    button.frame = CGRectMake(0, 0, 20, 20);
    [button setBackgroundImage:Bigimage forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc]initWithCustomView:button];
}

+ (UIBarButtonItem *)itemWithNormalImage:(NSString *)image target:(id)target action:(SEL)action width:(CGFloat)width height:(CGFloat)height{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *Bigimage = [UIImage imageNamed:image];
    
    button.frame = CGRectMake(0, 0, width, height);
    [button setBackgroundImage:Bigimage forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc]initWithCustomView:button];
}

+ (UIBarButtonItem *)itemWithTitle:(NSString *)title titleColor:(UIColor *)titleColor target:(id)target action:(SEL)action{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    button.frame = CGRectMake(0, 0, 40, 40);
    [button setTitle:title forState:UIControlStateNormal];
    [button setTintColor:titleColor];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc]initWithCustomView:button];

}

#pragma other(redPoint)
//添加显示
- (void)showRedAtOffSetX:(float)offsetX AndOffSetY:(float)offsetY OrValue:(NSString *)value{
    [self removeRedPoint];//添加之前先移除，避免重复添加
    //新建小红点
    UIView *badgeView = [[UIView alloc]init];
    badgeView.tag = 998;
    
    CGFloat viewWidth = 12;
    if (value) {
        viewWidth = 18;
        UILabel *valueLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, viewWidth, viewWidth)];
        valueLbl.text = value;
        //valueLbl.font = FONT_12;
        valueLbl.textColor = [UIColor whiteColor];
        valueLbl.textAlignment = NSTextAlignmentCenter;
        valueLbl.clipsToBounds = YES;
        [badgeView addSubview:valueLbl];
    }
    
    badgeView.layer.cornerRadius = viewWidth / 2;
    badgeView.backgroundColor = [UIColor redColor];
    CGRect tabFrame = self.customView.frame;
    
    //确定小红点的位置
    if (offsetX == 0) {
        offsetX = 1;
    }
    
    if (offsetY == 0) {
        offsetY = 0.05;
    }
    CGFloat x = ceilf(tabFrame.size.width + offsetX);
    CGFloat y = ceilf(offsetY * tabFrame.size.height);
    
    badgeView.frame = CGRectMake(x, y, viewWidth, viewWidth);
    [self.customView addSubview:badgeView];
}

//隐藏
- (void)hideRedPoint{
    [self removeRedPoint];
}

//移除
- (void)removeRedPoint{
    //按照tag值进行移除
    for (UIView *subView in self.customView.subviews) {
        if (subView.tag == 998) {
            [subView removeFromSuperview];
        }
    }
}
@end