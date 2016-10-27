//
//  PanViewController.h
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/8/26.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^coverDidRomove)();

@interface PanViewController : UIViewController

/**
 * 遮盖按钮
 */
@property (nonatomic, strong) UIButton *coverBtn;

/**
 * 完成滑动的回调
 */
@property (nonatomic, strong) coverDidRomove coverDidRomove;

/**
 * 是否在缩放中
 */
@property (nonatomic, assign) BOOL isScale;

- (void)coverClick;

- (void)leftClick;

@end
