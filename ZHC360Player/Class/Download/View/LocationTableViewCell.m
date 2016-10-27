//
//  LocationTableViewCell.m
//  下载工具
//
//  Created by 4DAGE_HUA on 16/10/12.
//  Copyright © 2016年 ZHC. All rights reserved.
//

#import "LocationTableViewCell.h"
#import "VideoModel.h"

@interface LocationTableViewCell ()

@property (strong, nonatomic) NSIndexPath *cellIndex;

@end

@implementation LocationTableViewCell

+ (LocationTableViewCell *)cellWithTableView:(UITableView *)tableview andModel:(VideoModel *)model{
    
    static NSString *ID = @"LocativeCell";
    LocationTableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:ID];
    
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([LocationTableViewCell class]) owner:nil options:nil] lastObject];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.layer.masksToBounds = YES;
    cell.nameLabel.text = model.name;
    cell.dateLabel.text = model.dateString;
    return cell;
}

- (NSIndexPath *)cellIndex{
    
    if (!_cellIndex) {
        
        _cellIndex = [[self tableview] indexPathForCell:self];
    }
    return _cellIndex;
}

// 移除本地文件
- (IBAction)removeFileButtonClick:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(removeButtonClickActionAtIndexPath:)]) {
        [self.delegate removeButtonClickActionAtIndexPath:self.cellIndex];
    }
}

// 显示cell下半部分更多操作
- (IBAction)moreDetailButtonClick:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(cellButtonClickAtIndexPath:)]) {
        [self.delegate cellButtonClickAtIndexPath:self.cellIndex];
    }
    
    // 对按钮的方向进行旋转
    if (_isExpand) {
        
        [UIView animateWithDuration:0.5 animations:^{
            _moreDetailButton.transform = CGAffineTransformMakeRotation(0);
        } completion:^(BOOL finished) {
            _isExpand = NO;
        }];
        
    }else{
        
        [UIView animateWithDuration:0.5 animations:^{
            _moreDetailButton.transform = CGAffineTransformMakeRotation(M_PI);
        } completion:^(BOOL finished) {
            _isExpand = YES;
        }];
    }
}

- (void)resetButtonIcon{
    
    // 对按钮的方向进行旋转
    if (_isExpand) {
        
        [UIView animateWithDuration:0.5 animations:^{
            _moreDetailButton.transform = CGAffineTransformMakeRotation(0);
        } completion:^(BOOL finished) {
            _isExpand = NO;
        }];
        
    }else{
        
        [UIView animateWithDuration:0.5 animations:^{
            _moreDetailButton.transform = CGAffineTransformMakeRotation(M_PI);
        } completion:^(BOOL finished) {
            _isExpand = YES;
        }];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
