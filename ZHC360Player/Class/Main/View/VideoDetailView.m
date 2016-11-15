//
//  VideoDetailView.m
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/11/4.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import "VideoDetailView.h"
#import "VideoModel.h"
#import "Util.h"
#import <CommonCrypto/CommonDigest.h>

@interface VideoDetailView ()

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UIButton *openPlayerBtn;

@property (nonatomic, strong) UIButton *cancelBtn;

@property (nonatomic, strong) UIImageView *videoImageview;

@end

@implementation VideoDetailView

- (instancetype)initWithVideoModel:(VideoModel *)model{
    
    if (self = [super init]) {
        
        UIImageView *theImgView    = [[UIImageView alloc]init];
        UILabel *theLabel          = [[UILabel alloc]init];
        UIButton *theButton        = [[UIButton alloc]init];
        UIButton *theCancelButton  = [[UIButton alloc]init];


        [self addSubview:theImgView];
        [self addSubview:theLabel];
        [self addSubview:theButton];
        [self addSubview:theCancelButton];
        
        self.nameLabel      = theLabel;
        self.videoImageview = theImgView;
        self.openPlayerBtn  = theButton;
        self.cancelBtn      = theCancelButton;

        [self setupWithModel:(VideoModel *)model];
        self.backgroundColor = [UIColor whiteColor];
        self.nameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:21.0f];
        self.nameLabel.textColor = ZHColor(0, 175, 230);
        [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [self.cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.openPlayerBtn setTitle:@"播放" forState:UIControlStateNormal];
        [self.openPlayerBtn setTitleColor:ZHColor(0, 175, 230) forState:UIControlStateNormal];
    }
    return self;
}

- (void)setupWithModel:(VideoModel *)model{
    
    [self.videoImageview sd_setImageWithURL:[NSURL URLWithString:model.imageUrlStr]];
    self.nameLabel.text = model.name;
    [self.openPlayerBtn addTarget:self action:@selector(openPlayer:) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)openPlayer:(id)sender{
    
    
    if ([self.delegate respondsToSelector:@selector(playVideoAction:)]) {
        [self.delegate playVideoAction:self.nameLabel.text];
    }
}

- (void)cancelAction{
    
    [self removeFromSuperview];
}

// 圆角
//- (void)imageCut{
//    
//    // Begin a new image that will be the new image with the rounded corners
//    // (here with the size of an UIImageView)
//    UIGraphicsBeginImageContextWithOptions(self.imgView.bounds.size, NO, 1.0);
//    
//    // Add a clip before drawing anything, in the shape of an rounded rect
//    [[UIBezierPath bezierPathWithRoundedRect:self.imgView.bounds
//                                cornerRadius:13.0] addClip];
//    // Draw your image
//    [self.imgView.image drawInRect:self.imgView.bounds];
//    
//    // Get the image, here setting the UIImageView image
//    self.imgView.image = UIGraphicsGetImageFromCurrentImageContext();
//    
//    UIGraphicsEndImageContext();
//}

// 颜色，约束
- (void)layoutSubviews{
    
    __weak typeof(self) weakSelf = self;
    [self.videoImageview mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(CGSizeMake(weakSelf.width - 40, weakSelf.height/2 - 10));
        make.top.equalTo(weakSelf.mas_top).offset(10);
        make.centerX.equalTo(weakSelf);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
         CGSize size = [weakSelf sizeWithString:weakSelf.nameLabel.text font:weakSelf.nameLabel.font constraintSize:weakSelf.videoImageview.size];
        make.size.mas_equalTo(CGSizeMake(2*size.width, size.height));
       //[weakSelf.nameLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:weakSelf.nameLabel.font,NSFontAttributeName, nil]];
        make.left.equalTo(weakSelf.videoImageview.mas_left).offset(10);
        make.bottom.equalTo(weakSelf.videoImageview.mas_bottom).offset(-10);
    }];
    
    [self.openPlayerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(CGSizeMake(weakSelf.width/2 - 50, 35));
        make.bottom.equalTo(weakSelf.mas_bottom).offset(-20);
        make.right.equalTo(weakSelf.mas_right).offset(-20);
    }];
    
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(CGSizeMake(weakSelf.width/2 - 50, 35));
        make.bottom.equalTo(weakSelf.mas_bottom).offset(-20);
        make.left.equalTo(weakSelf.mas_left).offset(20);
    }];
    
    self.layer.shouldRasterize = YES;
    self.layer.masksToBounds = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.layer.cornerRadius = 8;
}

- (CGSize)sizeWithString:(NSString *)string font:(UIFont *)font constraintSize:(CGSize)constraintSize{
    
    CGSize stringSize = CGSizeZero;
    
    NSDictionary *attributes = @{NSFontAttributeName:font};
    NSInteger options = NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin;
    CGRect stringRect = [string boundingRectWithSize:constraintSize options:options attributes:attributes context:NULL];
    stringSize = stringRect.size;
    
    return stringSize;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    
//    
//    
//}


@end
