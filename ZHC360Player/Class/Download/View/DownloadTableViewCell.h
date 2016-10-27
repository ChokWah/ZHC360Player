//
//  DownloadTableViewCell.h
//  下载工具
//
//  Created by 4DAGE_HUA on 16/10/14.
//  Copyright © 2016年 ZHC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VideoModel;
@protocol DownloadTableViewCellChangeStateDelegate  <NSObject>

- (void)cellChangeStateAtIndexPath:(NSIndexPath *)indexp;

@end

@interface DownloadTableViewCell : UITableViewCell

//==============================================属性================================================================

/** 显示详情*/
@property (strong, nonatomic) IBOutlet UILabel     *detaillabel;

/** 背景图片*/
@property (strong, nonatomic) IBOutlet UIImageView *imageview;

/** 名字*/
@property (strong, nonatomic) IBOutlet UILabel     *textlabel;

/** 暂停，恢复按钮*/
@property (strong, nonatomic) IBOutlet UIButton    *changeButton;

/** 用于在cell内部获取行数*/
@property (weak  , nonatomic)          UITableView *tableview;

/** 是否下载中*/
@property (assign, nonatomic)  BOOL isDownloading;

/** 委托，在按钮点击时对当前任务暂停或者恢复*/
@property (weak  , nonatomic)  id<DownloadTableViewCellChangeStateDelegate> delegate;
//==============================================方法================================================================

+ (DownloadTableViewCell *)cellWithTableView:(UITableView *)tableview andDownloadModel:(VideoModel *)model;

- (void)cellDownloadFailed;
@end
