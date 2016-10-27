//
//  UIImage+Extension.m
//  ZH_4DAGE_AR
//
//  Created by 4DAGE_HUA on 16/4/18.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import "UIImage+Extension.h"
#import <Foundation/Foundation.h>

@implementation UIImage (Extension)

+ (UIImage *)imageWithColor:(UIColor *)color {
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}



@end
