//
//  ZHLeftMenuView.h
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/8/29.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZHLeftMenuViewDelegate <NSObject>

- (void)leftMenuViewButtonClcik;

@end

@interface ZHLeftMenuView : UIView

@property (nonatomic, weak) id <ZHLeftMenuViewDelegate> delegate;

- (void)coverIsRemove;

@end
