//
//  HomeTableViewCell.m
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/10/8.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import "HomeTableViewCell.h"
#import "VideoModel.h"
#import "DownloadViewController.h"

@interface HomeTableViewCell ()

@property (strong, nonatomic)VideoModel *videoModel;

@end

@implementation HomeTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView withVideoModel:(VideoModel *)model{
    
    static NSString *cellID = @"onlineCell";
    
    HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([HomeTableViewCell class]) owner:nil options:nil] lastObject];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.layer.masksToBounds = YES;
    //这里设置内容 , 调用cell的属性设置
    cell.testLabel.text = model.name;
    cell.videoModel = model;
    
#warning 这里需要学习SDWebImage 缓存图片刷新
    //[cell.backGoundImageView setImage:[UIImage imageWithContentsOfFile:model.imageUrlStr]];
    
    // 圆角
    // Begin a new image that will be the new image with the rounded corners
    // (here with the size of an UIImageView)
    UIGraphicsBeginImageContextWithOptions(cell.backGoundImageView.bounds.size, NO, 1.0);
    
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:cell.backGoundImageView.bounds
                                cornerRadius:13.0] addClip];
    // Draw your image
    [cell.backGoundImageView.image drawInRect:cell.backGoundImageView.bounds];
    
    // Get the image, here setting the UIImageView image
    cell.backGoundImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();
    
    return cell;
}

- (void)awakeFromNib{
    
    [super awakeFromNib];
    
    //设置内容和圆角
    self.backGoundImageView.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor lightGrayColor];
}

- (IBAction)showMoreOperations:(id)sender {
    
    // 获取当前的行数，提供给代理方法修改cell的高度
    NSIndexPath *indexp = [[self tableview] indexPathForCell:self];
    if ([self.delegate respondsToSelector:@selector(cellDetailButtonClickAtIndexPath:)]) {
        [self.delegate cellDetailButtonClickAtIndexPath:indexp];
    }
    
    // 对按钮的方向进行旋转
    if (_isExpand) {
        
        [UIView animateWithDuration:0.5 animations:^{
            _moreOperationsButton.transform = CGAffineTransformMakeRotation(0);
        } completion:^(BOOL finished) {
            _isExpand = NO;
        }];
        
    }else{
        
        [UIView animateWithDuration:0.5 animations:^{
            _moreOperationsButton.transform = CGAffineTransformMakeRotation(M_PI);
        } completion:^(BOOL finished) {
            _isExpand = YES;
        }];
    }
}

// 下载当前cell的视频
- (IBAction)downloadVideoAction:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(downloadActionWithModel:)]) {
        [self.delegate downloadActionWithModel:self.videoModel];
    }
}

- (void)resetButtonIcon{
    
    // 对按钮的方向进行旋转
    if (_isExpand) {
        
        [UIView animateWithDuration:0.5 animations:^{
            _moreOperationsButton.transform = CGAffineTransformMakeRotation(0);
        } completion:^(BOOL finished) {
            _isExpand = NO;
        }];
        
    }else{
        
        [UIView animateWithDuration:0.5 animations:^{
            _moreOperationsButton.transform = CGAffineTransformMakeRotation(M_PI);
        } completion:^(BOOL finished) {
            _isExpand = YES;
        }];
    }
}
@end
