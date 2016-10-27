//
//  UIColor+ZHColor.h
//  ZH_4DAGE_AR
//
//  Created by 4DAGE_HUA on 16/4/28.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (ZHColor)
/**
 返回随机颜色
 */
+ (instancetype)randColor;

/**
 *  将16进制字符串转换成UIColor
 */
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;
@end
