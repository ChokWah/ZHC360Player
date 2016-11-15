//
//  UIImageView+fillet.m
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/11/15.
//  Copyright © 2016年 4DAGE. All rights reserved.
//


/* 来自 简书作者 大灰灰iOS的文章：http://www.jianshu.com/p/d6817aa696f5/comments/1636657
   UIImageView ，UIimage 的 两个catagory结合SDWebimage解决圆角问题
   
   用UIBezierPath的CGpath添加到UIGraphicsBeginImageContextWithOptions
 
 
 */

#import "UIImageView+fillet.h"

@implementation UIImageView (fillet)

- (void)lhy_loadImageUrlStr:(NSString *)urlStr radius:(CGFloat)radius{
      
    //这里传CGFLOAT_MIN，就是默认以图片宽度的一半为圆角
    if (radius == CGFLOAT_MIN) {
        radius = self.frame.size.width/2.0;
    }
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    if (radius != 0.0) {
        //头像需要手动缓存处理成圆角的图片
        NSString *cacheurlStr = [urlStr stringByAppendingString:@"radiusCache"];
        UIImage *cacheImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:cacheurlStr];
        if (cacheImage) {
            self.image = cacheImage;
        }else {
            [self sd_setImageWithURL:url placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (!error) {
                    UIImage *radiusImage = [image drawRectWithRoundedCorner:radius size:self.bounds.size]; // 得到清晰圆角图片
                    //UIImage *radiusImage = [UIImage createRoundedRectImage:image size:self.frame.size radius:radius];
                    self.image = radiusImage;
                    [[SDImageCache sharedImageCache] storeImage:radiusImage forKey:cacheurlStr];
                    //清除原有非圆角图片缓存
                    [[SDImageCache sharedImageCache] removeImageForKey:urlStr];
                }
            }];
        }
    }else {
        [self sd_setImageWithURL:url placeholderImage:nil completed:nil];
    }

}



@end
