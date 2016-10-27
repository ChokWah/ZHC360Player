//
//  ZHLeftMenuView.m
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/8/29.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import "ZHLeftMenuView.h"

@implementation ZHLeftMenuView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setDelegate:(id<ZHLeftMenuViewDelegate>)delegate{
    
    _delegate = delegate;
    [self show];
}

- (void)show{
    
    if([self.delegate respondsToSelector:@selector(leftMenuViewButtonClcik)]){
        
        [self.delegate leftMenuViewButtonClcik];
    }
}
@end
