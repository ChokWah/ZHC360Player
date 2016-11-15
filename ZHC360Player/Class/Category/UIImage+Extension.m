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


- (UIImage *)drawRectWithRoundedCorner:(CGFloat)radius size:(CGSize)sizeToFit{
    
    // Begin a new image that will be the new image with the rounded corners
    // (here with the size of an UIImageView)
    // Add a clip before drawing anything, in the shape of an rounded rect
    // Draw your image
    // Get the image, here setting the UIImageView image
    
    CGRect rect = CGRectMake(0, 0, sizeToFit.width, sizeToFit.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, false, [UIScreen mainScreen].scale);
    
    CGContextAddPath(UIGraphicsGetCurrentContext(), [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, radius)].CGPath);
    CGContextClip(UIGraphicsGetCurrentContext());
    
    [self drawInRect:rect];
    CGContextDrawPath(UIGraphicsGetCurrentContext(), kCGPathFillStroke);
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}

@end
