//
//  ZHProgressView.h
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/11/9.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZHProgressView : UIView

@property (nonatomic, assign) CGFloat progress;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)setProgress:(CGFloat)progress;

@end
