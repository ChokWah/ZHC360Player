//
//  UIImage+Extension.h
//  ZH_4DAGE_AR
//
//  Created by 4DAGE_HUA on 16/4/18.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)

+ (UIImage *)imageWithColor:(UIColor *)color;

- (UIImage *)drawRectWithRoundedCorner:(CGFloat)radius size:(CGSize)sizeToFit;

@end
