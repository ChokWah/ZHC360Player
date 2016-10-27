//
//  DownloadTableViewCell.m
//  下载工具
//
//  Created by 4DAGE_HUA on 16/10/14.
//  Copyright © 2016年 ZHC. All rights reserved.
//


#import "DownloadTableViewCell.h"
#import "VideoModel.h"

@implementation DownloadTableViewCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.layer.masksToBounds = YES;
    [self.changeButton  setImage:[UIImage imageNamed:@"suspend_icon"] forState:UIControlStateNormal];
    self.changeButton.backgroundColor = [UIColor grayColor];
}

+ (DownloadTableViewCell *) cellWithTableView:(UITableView *)tableview andDownloadModel:(VideoModel *)model{
    
    static NSString *ID = @"downloadCell";
    DownloadTableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:ID];
    
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DownloadTableViewCell class]) owner:nil options:nil] lastObject];
    }
    cell.textlabel.text = model.name;
    cell.detaillabel.text = model.progressInfo;
    cell.isDownloading = YES;
    return cell;
}

- (IBAction)changeButtonStateAction:(id)sender {
    
    // 获取当前的行数，提供给代理方法修改cell的高度
    NSIndexPath *indexp = [[self tableview] indexPathForCell:self];
    
    if (self.isDownloading) {
        
        [self.changeButton  setImage:[UIImage imageNamed:@"download_icon"] forState:UIControlStateNormal];
        self.isDownloading = NO;
        
    }else{
        
        [self.changeButton  setImage:[UIImage imageNamed:@"suspend_icon"] forState:UIControlStateNormal];
        self.isDownloading = YES;
    }
    
    if ([self.delegate respondsToSelector:@selector(cellChangeStateAtIndexPath:)]) {
        [self.delegate cellChangeStateAtIndexPath:indexp];
    }
}

- (void)cellDownloadFailed{
    
    self.isDownloading = YES;
    [self changeButtonStateAction:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}
@end
