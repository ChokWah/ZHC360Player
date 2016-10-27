//
//  UIBarButtonItem_ZHExtension.h
//  ZH_4DAGE_AR
//
//  Created by 4DAGE_HUA on 16/4/14.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (ZHExtension)

+ (instancetype)itemWithImage:(NSString *)image highImage:(NSString *)highImage target:(id)target action:(SEL)action;


/**
 *  根据图片快速创建一个UIBarButtonItem，返回小号barButtonItem
 */
+ (UIBarButtonItem *)itemWithNormalImage:(NSString *)image target:(id)target action:(SEL)action;


/**
 *  根据图片快速创建一个UIBarButtonItem，返回大号barButtonItem
 */
+ (UIBarButtonItem *)itemWithBigImage:(NSString *)image target:(id)target action:(SEL)action;



/**
 *  根据图片快速创建一个UIBarButtonItem，大小自定义
 */
+ (UIBarButtonItem *)itemWithNormalImage:(NSString *)image target:(id)target action:(SEL)action width:(CGFloat)width height:(CGFloat)height;


/**
 *  根据文字快速创建一个UIBarButtonItem，大小自定义
 */
+ (UIBarButtonItem *)itemWithTitle:(NSString *)title titleColor:(UIColor *)titleColor target:(id)target action:(SEL)action;

/**
 *  加上红色小圆点
 */
- (void)showRedAtOffSetX:(float)offsetX AndOffSetY:(float)offsetY OrValue:(NSString *)value;

/**
 *  隐藏小圆点
 */
- (void)hideRedPoint;
@end
