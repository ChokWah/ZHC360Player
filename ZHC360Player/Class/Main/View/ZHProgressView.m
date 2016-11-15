//
//  ZHProgressView.m
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/11/9.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import "ZHProgressView.h"

// Degrees to radians
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
@interface ZHProgressView (){
     UIBezierPath *pathBezier;
     CAShapeLayer *stopLayer;
}

@end

@implementation ZHProgressView


- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        stopLayer = [[CAShapeLayer alloc]init];
        stopLayer.frame = CGRectMake(23, 23, 14, 14);
        stopLayer.backgroundColor = ZHColor( 0, 175, 230).CGColor;
        [self.layer addSublayer:stopLayer];
        [stopLayer setHidden:YES];
    }
    return self;
}

- (void)setProgress:(CGFloat)progress{
    
    _progress = progress;
    // 重新绘制:在view上做一个重绘的标记，当下次屏幕刷新的时候，就会调用drawRect.
    [self setNeedsDisplay];
}

- (void)setHidden:(BOOL)hidden{
    
    [stopLayer setHidden:hidden];
    [super setHidden:hidden];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {

    CGPoint center = CGPointMake(30, 30);
    pathBezier = [UIBezierPath bezierPathWithArcCenter:center
                                                        radius:25
                                                    startAngle:-M_PI_2
                                                      endAngle:-M_PI_2 + _progress * M_PI * 2
                                                     clockwise:YES];
    
    pathBezier.lineCapStyle = kCGLineCapRound;
    pathBezier.lineJoinStyle = kCGLineJoinRound;
    pathBezier.lineWidth = 5.0;
    
    UIColor *strokeColor = ZHColor( 0, 175, 230);
    [strokeColor set];
    [pathBezier stroke];
}

@end
