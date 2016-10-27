//
//  UIImageView+WebCache.h
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/8/23.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZHImageCacheType) {
    
    ZHImageCacheTypeNone,
    
    ZHImageCacheTypeDisk,
    
    ZHImageCacheTypeMemory
};

typedef void(^ZHWebImageCompletionBlock)(UIImage *image, NSError *error, ZHImageCacheType cacheType, NSURL *imageURL);

@interface UIImageView (WebCache)

- (void)zh_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder  completed:(ZHWebImageCompletionBlock)completedBlock;


- (void)zh_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;
@end
