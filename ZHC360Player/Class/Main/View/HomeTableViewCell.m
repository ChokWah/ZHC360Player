//
//  HomeTableViewCell.m
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/4/28.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import "HomeTableViewCell.h"
#import "VideoModel.h"
#import "UIImageView+WebCache.h"
#import "ZHProgressView.h"

@interface HomeTableViewCell ()

@property (assign, nonatomic)NSUInteger index;

@property (strong, nonatomic)ZHProgressView *progressView;

@end

@implementation HomeTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView withVideoModel:(VideoModel *)model{
    
    static NSString *cellID = @"onlineCell";
    HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([HomeTableViewCell class]) owner:nil options:nil] lastObject];
        [cell setWidth:ZHAppWidth];
        [cell.progressView setHidden:YES];
        cell.progressView = [[ZHProgressView alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
        [cell.contentView addSubview:cell.progressView];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    //cell.layer.masksToBounds = YES;
    //cell.backGoundImageView.layer.masksToBounds = YES;
    
    //这里设置内容 , 调用cell的属性设置
    cell.nameLabel.text = model.name;
    cell.index = model.index;
    [cell.backGoundImageView lhy_loadImageUrlStr:model.imageUrlStr radius:10];
    
    if (model.tempDataSize != 0) {
        
        [cell.progressView setHidden:NO];
        [cell.progressView setProgress:(CGFloat)((CGFloat)model.tempDataSize / (CGFloat)model.totalSize)];
        (model.tempDataSize == model.totalSize) ? [cell.progressView setHidden:YES] : nil;
        
    }
    
    return cell;
}

- (void)updateProgress:(CGFloat)progress{
    
    [self.progressView setProgress:progress];
}

- (void)setFrame:(CGRect)frame{
    
    __weak typeof(self) weakSelf = self;
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(CGSizeMake(60, 60));
        make.right.equalTo(weakSelf.mas_right).offset(-25);
        make.centerY.mas_equalTo(weakSelf.mas_centerY);
    }];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(stopAction:)];
    [self.progressView addGestureRecognizer:tap];
    [super setFrame:frame];
}

- (void)stopAction:(id)sender{
    
    [self.progressView setHidden:YES];
    if ([self.delegate respondsToSelector:@selector(stopDownloadAction:)]) {
        [self.delegate stopDownloadAction:self.index];
    }
}



@end
